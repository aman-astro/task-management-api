class Comment < ApplicationRecord
    belongs_to :task
    belongs_to :user

    validates :content, presence: true
    validates :task, presence: true
    validates :user, presence: true
end
