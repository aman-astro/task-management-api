class Api::V1::ProjectsController < Api::V1::BaseController
  before_action :set_project, only: [:show, :update, :destroy]

  # GET /api/v1/projects
  def index
    @projects = current_user.projects.includes(:tasks)
    render_success(
      @projects.map { |project| ProjectSerializer.new(project) },
      'Projects retrieved successfully'
    )
  end

  # GET /api/v1/projects/:id
  def show
    render_success(
      ProjectSerializer.new(@project),
      'Project retrieved successfully'
    )
  end

  # POST /api/v1/projects
  def create
    @project = current_user.projects.build(project_params)

    if @project.save
      render_success(
        ProjectSerializer.new(@project),
        'Project created successfully',
        :created
      )
    else
      render_error(
        'Project creation failed',
        @project.errors.full_messages,
        :unprocessable_entity
      )
    end
  end

  # PATCH/PUT /api/v1/projects/:id
  def update
    if @project.update(project_params)
      render_success(
        ProjectSerializer.new(@project),
        'Project updated successfully'
      )
    else
      render_error(
        'Project update failed',
        @project.errors.full_messages,
        :unprocessable_entity
      )
    end
  end

  # DELETE /api/v1/projects/:id
  def destroy
    @project.destroy
    render_success(
      nil,
      'Project deleted successfully'
    )
  end

  private

  def set_project
    @project = current_user.projects.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Project not found or you do not have access to it')
  end

  def project_params
    params.require(:project).permit(:title, :description)
  end
end
