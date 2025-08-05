class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :status, :due_date, :created_at, :updated_at, :project_id
  
  # Include basic project info (avoid circular reference)
  attribute :project do
    {
      id: object.project.id,
      title: object.project.title
    }
  end
  
  # Include comments count
  attribute :comments_count do
    object.comments.count
  end
end
