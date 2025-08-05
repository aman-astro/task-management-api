class Api::V1::TasksController < Api::V1::BaseController
  before_action :set_task, only: [:show, :update, :destroy]

  # GET /api/v1/projects/:project_id/tasks
  def index
    # Project ID is required
    unless params[:project_id].present?
      render_not_found('Project not found')
      return
    end

    # Get project-specific tasks only
    @project = current_user.projects.find(params[:project_id])
    @tasks = @project.tasks.includes(:project, :comments)
    
    # Apply filters based on query parameters
    @tasks = apply_filters(@tasks)

    # Pagination
    @tasks = @tasks.page(params[:page]).per(params[:per_page] || 10)

    render_success(
      {
        tasks: @tasks.map { |task| TaskSerializer.new(task) },
        pagination: {
          current_page: @tasks.current_page,
          total_pages: @tasks.total_pages,
          total_count: @tasks.total_count,
          per_page: @tasks.limit_value
        }
      },
      'Tasks retrieved successfully'
    )
  rescue ActiveRecord::RecordNotFound
    render_not_found('Project not found')
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
    @task.soft_delete
    render_success(
      nil,
      'Task deleted successfully'
    )
  end

  # GET /api/v1/tasks/all
  def all
    @tasks = Task.joins(:project).where(projects: { user: current_user }).includes(:project, :comments)
    @tasks = apply_filters(@tasks)
    @tasks = @tasks.page(params[:page]).per(params[:per_page] || 10)
    render_success(
      {
        tasks: @tasks.map { |task| TaskSerializer.new(task) },
        pagination: {
          current_page: @tasks.current_page,
          total_pages: @tasks.total_pages,
          total_count: @tasks.total_count,
          per_page: @tasks.limit_value
        }
      },
      'All tasks retrieved successfully'
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

  def apply_filters(tasks)
    # Filter by status if provided
    if params[:status].present?
      # Support multiple statuses separated by comma
      statuses = params[:status].split(',').map(&:strip)
      # Validate that all statuses are valid
      valid_statuses = statuses.select { |status| Task.statuses.key?(status) }
      
      if valid_statuses.any?
        tasks = tasks.where(status: valid_statuses)
      end
    end

    # Filter by due date if provided (tasks due before this date)
    if params[:due_date].present?
      begin
        tasks = tasks.where('due_date < ?', Date.parse(params[:due_date]))
      rescue ArgumentError
        # Invalid date format, ignore filter
      end
    end

    tasks
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :due_date, :project_id)
  end
end