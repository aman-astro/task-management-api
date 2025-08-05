class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content, :created_at, :updated_at, :task_id, :user_id
end
