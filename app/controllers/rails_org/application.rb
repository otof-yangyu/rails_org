module RailsOrg::Application
  extend ActiveSupport::Concern
  included do
    helper_method :current_organ, :current_member, :other_organs
    before_action :set_filter_params
    after_action :set_organ_grant
  end

  def require_organ
    return if current_organ
    
    respond_to do |format|
      format.json do
        render json: { message: '请登录后操作' }, status: 401
      end
      format.html do
        redirect_to RailsOrg.config.default_return_path
      end
    end
  end
  
  def require_member
    return if current_member

    respond_to do |format|
      format.json do
        render json: { message: '请登录后操作' }, status: 401
      end
      format.html do
        redirect_to RailsOrg.config.default_return_path
      end
    end
  end

  # Must order after RailsRole::Controller
  def rails_role_user
    if current_member
      current_member
    else
      current_user
    end
  end
  
  def current_receiver
    if current_member
      current_member
    else
      current_user
    end
  end

  def current_member
    return @current_member if defined?(@current_member)
    @current_member = current_organ_grant&.member
  end

  def current_organ
    return @current_organ if defined?(@current_organ)
    @current_organ = current_organ_grant&.organ
  end

  def current_organ_grant
    return @current_organ_grant if defined?(@current_organ_grant)
    token = request.headers['Organ-Token'].presence || session[:organ_token]
    return unless token
    @current_organ_grant = ::OrganGrant.find_by(token: token)
  end

  def other_organs
    current_user.organs.where.not(id: current_organ.id)
  end
  
  # Must order after RailsAuth::Controller
  def login_by_account(account)
    super
    if account.members.size == 1
      @current_member = account.members.first
      @current_organ = @current_member.organ
      logger.debug "  ==========> Login by account as member: #{@current_member.id}"
    else
      logger.debug "  ==========> There are more than one organs, please goto select one;"
    end
  end

  def login_organ_as(organ_grant)
    logger.debug "  ==========> Login as Organ #{organ_grant.organ_id}"
    @current_organ_grant = organ_grant
    session[:organ_id] = organ_grant.organ_id
  end

  def set_organ_grant
    if defined?(@current_organ_grant)
      token = @current_organ_grant.token
    else
      return
    end
    
    headers['Organ-Token'] = token
    session[:organ_token] = token
  end
  
  def set_filter_params
    session[:organ_id] = params[:organ_id].presence if params.key?(:organ_id)
  end
  
  def current_organ_id
    request.subdomain.delete_prefix('organ_').presence if request.subdomain.start_with?('organ_')
  end

  def default_params
    if current_organ
      { organ_id: current_organ.id }
    elsif current_organ_id
      { organ_id: current_organ_id }
    else
      { organ_id: nil, allow: { organ_id: nil } }
    end
  end
  
  def default_form_params
    if current_organ
      { organ_id: current_organ.id }
    else
      {}
    end
  end
  
  def default_filter_params
    unless current_organ
      return {}
    end
    
    if current_organ.self_and_descendant_ids.include?(session[:organ_id].to_i)
      { organ_id: session[:organ_id] }
    else
      { organ_id: current_organ.self_and_descendant_ids }
    end
  end

  def organ_ancestors_params
    if current_organ
      { organ_id: current_organ.self_and_ancestor_ids }
    else
      default_params
    end
  end

end
