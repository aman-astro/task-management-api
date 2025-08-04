class User < ApplicationRecord
  # Include only necessary devise modules for stateless JWT API
  devise :database_authenticatable, :registerable, :validatable, 
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  has_many :comments, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :tasks, through: :projects

  validates :name, presence: true
  # email validation is handled by Devise :validatable
end
