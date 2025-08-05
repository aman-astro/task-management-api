class Api::V1::TasksController < Api::V1::BaseController
  before_action :set_task, only: [:show, :update, :destroy]

  # GET /api/v1/tasks
  def index
    @tasks = Task.joins(:project).where(projects: { user: current_user })
                 .includes(:project, :comments)
    render_success(
      @tasks.map { |task| TaskSerializer.new(task) },
      'Tasks retrieved successfully'
    )
  end

  # GET /api/v1/tasks/:id
  def show
    render_success(
      TaskSerializer.new(@task),
      'Task retrieved successfully'
    )
  end

  # POST /api/v1/tasks
  def create
    @project = current_user.projects.find(task_params[:project_id])
    @task = @project.tasks.build(task_params.except(:project_id))

    if @task.save
      render_success(
        TaskSerializer.new(@task),
        'Task created successfully',
        :created
      )
    else
      render_error(
        'Task creation failed',
        @task.errors.full_messages,
        :unprocessable_entity
      )
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Project not found or you do not have access to it')
  end

  # PATCH/PUT /api/v1/tasks/:id
  def update
    if @task.update(task_params.except(:project_id))
      render_success(
        TaskSerializer.new(@task),
        'Task updated successfully'
      )
    else
      render_error(
        'Task update failed',
        @task.errors.full_messages,
        :unprocessable_entity
      )
    end
  end

  # DELETE /api/v1/tasks/:id
  def destroy
    @task.destroy
    render_success(
      nil,
      'Task deleted successfully'
    )
  end

  private

  def set_task
    @task = Task.joins(:project)
                .where(projects: { user: current_user })
                .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Task not found or you do not have access to it')
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :due_date, :project_id)
  end
end