class Org::Admin::OrganGrantsController < Org::Admin::BaseController
  before_action :set_member

  def index
    q_params = {}
    q_params.merge! organ_descendants_params
    @organ_grants = @member.organ_grants.default_where(q_params).page(params[:page])
  end

  def new
    @organ_grant = current_organ.organ_grants.build
  end

  def create
    @organ_grant = current_organ.organ_grants.build(organ_grant_params)

    unless @organ_grant.save
      render :new, locals: { model: @organ_grant }, status: :unprocessable_entity
    end
  end

  def destroy
    @organ_grant = current_organ.organ_grants.find(params[:id])
    @organ_grant.destroy
  end

  private
  def set_member
    @member = current_organ.members.find params[:member_id]
  end

  def organ_grant_params
    params.fetch(:organ_grant).permit(
      role_ids: []
    )
  end

end
