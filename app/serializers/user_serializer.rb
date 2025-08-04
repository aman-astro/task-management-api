class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at
  
  # Optional: Add computed attributes
  # attribute :projects_count do
  #   object.projects.count
  # end
end
