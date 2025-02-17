class Org::Panel::OrgansController < Org::Panel::BaseController
  before_action :set_organ, only: [:edit, :update, :mock, :destroy]

  def show
  end

  def edit
  end

  def update
    @organ.assign_attributes(organ_params)

    if @organ.save
      render 'update'
    else
      render :edit
    end
  end

  def mock
    organ_grant = @organ.get_organ_grant(current_member || current_user)
    login_organ_as(organ_grant)

    redirect_to current_admin_organs_url
  end

  def destroy
    @organ.destroy
    redirect_to admin_organs_url
  end

  private
  def set_organ
    @organ = current_organ
  end

  def organ_params
    params.fetch(:organ, {}).permit(
      :name,
      :logo,
      :intro,
      :parent_ancestors,
      :area_ancestors
    )
  end

  def organ_limit_params
    params.fetch(:organ, {}).permit(
      :limit_office,
      :limit_wechat
    )
  end

end
