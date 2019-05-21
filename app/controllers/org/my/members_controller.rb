class Org::My::MembersController < Org::My::BaseController
  before_action :set_member, only: [:show, :edit, :update, :login]

  def index
    @members = current_user.members
  end

  def show
    respond_to do |format|
      format.js
      format.html
      format.json
    end
  end

  def cert
    disposition = params[:disposition] || 'inline'
    @pdf ||= CertificationPdf.new(params[:member_badge_id])
    respond_to do |format|
      format.html
      format.js
      format.pdf { send_data @pdf.render, filename: 'cert_file', disposition: disposition, type: 'application/pdf' }
    end
  end

  def edit
  end

  def update
    @member.assign_attributes member_params
    respond_to do |format|
      if @member.save
        format.html { redirect_to my_member_url(@member) }
        format.json { render :show }
      else
        format.html { render action: 'edit' }
        format.json { render :show }
      end
    end
  end

  def login
    organ_token = @member.get_organ_token(params[:organ_id])
    login_organ_as organ_token

    respond_to do |format|
      format.html { redirect_to admin_organ_url }
      format.json { render json: { organ_grant: organ_token } }
    end
  end

  private
  def set_member
    @member = current_user.members.find params[:id]
  end

  def member_params
    params.fetch(:member, {}).permit(
      :name,
      :identity,
      :profession,
      :attendance_number,
      :next_on_time,
      :next_off_time,
      :experience,
      :avatar
    )
  end

end
