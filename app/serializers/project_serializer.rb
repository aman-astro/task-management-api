class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :created_at, :updated_at
  
  # Include associated user
  belongs_to :user, serializer: UserSerializer
  
  # Include tasks count
  attribute :tasks_count do
    object.tasks.count
  end
  
  # Include pending tasks count
  attribute :pending_tasks_count do
    object.tasks.pending.count
  end
end
