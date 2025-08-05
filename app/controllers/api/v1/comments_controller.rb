class Api::V1::CommentsController < Api::V1::BaseController
  before_action :set_comment, only: [:show, :update, :destroy]

  # GET /api/v1/comments/task_id/:task_id
  def by_task
    # Verify the task belongs to the current user
    @task = Task.joins(:project)
                .where(projects: { user: current_user })
                .find(params[:task_id])
    
    @comments = @task.comments.includes(:user)
    render_success(
      @comments.map { |comment| CommentSerializer.new(comment) },
      'Comments for task retrieved successfully'
    )
  rescue ActiveRecord::RecordNotFound
    render_not_found('Task not found or you do not have access to it')
  end

  # GET /api/v1/comments/user_id/:user_id
  def by_user
    # Get comments by user, but only for tasks that belong to the current user's projects
    @comments = Comment.joins(task: :project)
                       .where(projects: { user: current_user })
                       .where(user_id: params[:user_id])
                       .includes(:user, :task)
    render_success(
      @comments.map { |comment| CommentSerializer.new(comment) },
      'Comments by user retrieved successfully'
    )
  end

  # GET /api/v1/comments/:id
  def show
    render_success(
      CommentSerializer.new(@comment),
      'Comment retrieved successfully'
    )
  end

  # POST /api/v1/comments
  def create
    @task = Task.joins(:project)
                .where(projects: { user: current_user })
                .find(comment_params[:task_id])
    
    @comment = @task.comments.build(comment_params.except(:task_id))
    @comment.user = current_user

    if @comment.save
      render_success(
        CommentSerializer.new(@comment),
        'Comment created successfully',
        :created
      )
    else
      render_error(
        'Comment creation failed',
        @comment.errors.full_messages,
        :unprocessable_entity
      )
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Task not found or you do not have access to it')
  end

  # PATCH/PUT /api/v1/comments/:id
  def update
    if @comment.update(comment_params.except(:task_id))
      render_success(
        CommentSerializer.new(@comment),
        'Comment updated successfully'
      )
    else
      render_error(
        'Comment update failed',
        @comment.errors.full_messages,
        :unprocessable_entity
      )
    end
  end

  # DELETE /api/v1/comments/:id
  def destroy
    @comment.destroy
    render_success(
      nil,
      'Comment deleted successfully'
    )
  end

  private

  def set_comment
    @comment = Comment.joins(task: :project)
                      .where(projects: { user: current_user })
                      .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Comment not found or you do not have access to it')
  end

  def comment_params
    params.require(:comment).permit(:content, :task_id)
  end
end