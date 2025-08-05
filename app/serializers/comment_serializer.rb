class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content, :created_at, :updated_at, :task_id, :user_id
  
  # Include basic user info (comment author)
  attribute :user do
    {
      id: object.user.id,
      name: object.user.name,
      email: object.user.email
    }
  end
  
  # Include basic task info (avoid circular reference)
  attribute :task do
    {
      id: object.task.id,
      title: object.task.title,
      project_id: object.task.project_id
    }
  end
end
