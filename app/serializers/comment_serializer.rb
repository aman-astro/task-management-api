class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content, :created_at, :updated_at
  
  # Include associated user (author of comment)
  belongs_to :user, serializer: UserSerializer
  
  # Include associated task
  belongs_to :task, serializer: TaskSerializer
end
