class Task < ApplicationRecord
    belongs_to :project
    has_many :comments, dependent: :destroy

    validates :title, presence: true
    validates :project, presence: true

    validates :title, uniqueness: { scope: :project_id }
    enum :status, { pending: 0, in_progress: 1, completed: 2 }
end
