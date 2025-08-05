class User < ApplicationRecord
  # Include necessary devise modules
  devise :database_authenticatable, :registerable, :validatable

  has_many :comments, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :tasks, through: :projects

  validates :name, presence: true
  # email validation is handled by Devise :validatable
end
