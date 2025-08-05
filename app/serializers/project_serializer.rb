class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :created_at, :updated_at, :user_id
  
  # Include basic user info
  attribute :user do
    {
      id: object.user.id,
      name: object.user.name,
      email: object.user.email
    }
  end
  
  # Include tasks count
  attribute :tasks_count do
    object.tasks.count
  end
  
  # Include pending tasks count
  attribute :pending_tasks_count do
    object.tasks.pending.count
  end
  
  # Include completed tasks count
  attribute :completed_tasks_count do
    object.tasks.completed.count
  end
  
  # Include in_progress tasks count
  attribute :in_progress_tasks_count do
    object.tasks.in_progress.count
  end
end
