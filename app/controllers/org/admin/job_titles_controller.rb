class Org::Admin::JobTitlesController < Org::Admin::BaseController
  before_action :set_department
  before_action :set_job_title, only: [:show, :edit, :update, :move_higher, :move_lower, :reorder, :destroy]

  def index
    q_params = {
      department_root_id: @department.root.id
    }
    q_params.merge! default_params
    q_params.merge! params.permit(:name)
    
    @job_titles = DepartmentJobTitle.default_where(q_params).page(params[:page])

    @selected_job_titles = JobTitle.where.not(super_job_title_id: nil).default_where(q_params).order(grade: :asc)
    @super_job_titles = SuperJobTitle.default_where(default_params).order(grade: :asc)
  end

  def new
    @job_title = @department.job_titles.build
  end

  def create
    @job_title = @department.job_titles.build(job_title_params)

    respond_to do |format|
      if @job_title.save
        format.html.phone
        format.html { redirect_to admin_department_job_titles_url(@department) }
        format.js { redirect_to admin_department_job_titles_url(@department) }
        format.json { render :show }
      else
        format.html.phone { render :new }
        format.html { render :new }
        format.js { redirect_to admin_department_job_titles_url(@department), status: :unprocessable_entity }
        format.json { render :show }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    @job_title.assign_attributes(job_title_params)

    respond_to do |format|
      if @job_title.save
        format.html.phone
        format.html { redirect_to admin_job_titles_url(department_id: @job_title.department_id) }
        format.js { redirect_to admin_job_titles_url(department_id: @job_title.department_id) }
        format.json { render :show }
      else
        format.html.phone { render :edit }
        format.html { render :edit }
        format.js { redirect_to admin_job_titles_url(department_id: @job_title.department_id) }
        format.json { render :show }
      end
    end
  end

  def move_higher
    @job_title.move_higher
    redirect_to admin_department_job_titles_url(@department)
  end

  def move_lower
    @job_title.move_lower
    redirect_to admin_department_job_titles_url(@department)
  end

  def reorder
    sort_array = params[:sort_array].select { |i| i.integer? }
  
    if params[:new_index] > params[:old_index]
      prev_one = @job_title.same_job_titles.find(sort_array[params[:new_index].to_i - 1])
      @job_title.insert_at prev_one.position
    else
      next_ones = @job_title.same_job_titles.find(sort_array[(params[:new_index].to_i + 1)..params[:old_index].to_i])
      next_ones.each do |next_one|
        next_one.insert_at @job_title.position
      end
    end
  end

  def destroy
    @job_title.destroy
    redirect_to admin_department_job_titles_url(@department)
  end

  private
  def set_department
    @department = Department.find params[:department_id]
  end

  def set_job_title
    @job_title = JobTitle.where(department_root_id: @department.root.id).find(params[:id])
  end

  def job_title_params
    p = params.fetch(:job_title, {}).permit(
      :name,
      :description,
      :grade,
      :super_job_title_id
    )
    p.merge! default_params
  end

end
