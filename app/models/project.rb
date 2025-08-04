class Project < ApplicationRecord
    belongs_to :user
    has_many :tasks, dependent: :destroy

    validates :title, presence: true
    validates :user, presence: true

    validates :title, uniqueness: { scope: :user_id }
end
