class Org::Mine::OrgansController < Org::Mine::BaseController
  before_action :set_organ, only: [:show, :edit, :update, :destroy]

  def index
    @organs = current_user.organs.distinct.page(params[:page])
    session.delete :organ_token
  end

  def new
    @member = current_user.members.build
    @organ = @member.build_organ
  end

  def create
    parent_uuid = params.dig(:member, :parent_uuid)
    parent_organ_id =
      if parent_uuid.present?
        Organ.find_by(organ_uuid: parent_uuid)&.id
      else
        nil
      end

    @member = current_user.members.build(member_params)
    @member.build_organ(organ_params.merge(parent_id: parent_organ_id))

    unless @member.save
      render :new, locals: { model: @member }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @organ.assign_attributes(organ_params)

    unless @organ.save
      render :edit, locals: { model: @organ }, status: :unprocessable_entity
    end
  end

  def destroy
    @organ.destroy
  end

  private
  def set_member
    @member = current_user.members.find params[:member_id]
  end

  def set_organ
    @organ = Organ.find(params[:id])
  end

  def member_params
    p = params.fetch(:member, {}).permit(:identity)
    p.merge! owned: true
  end

  def organ_params
    params.fetch(:member, {}).fetch(:organ_attributes, {}).permit(
      :name,
      :logo
    )
  end

end
