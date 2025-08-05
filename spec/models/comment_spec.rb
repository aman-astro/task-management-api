require 'rails_helper'

describe Comment, type: :model do
  subject {
    Comment.new(
      content: "A comment",
      task: Task.new(title: "Task", project: Project.new(title: "Project", user: User.new(name: "Test", email: "test@example.com", password: "password123"))),
      user: User.new(name: "Test", email: "test@example.com", password: "password123")
    )
  }

  context 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:task) }
    it { should validate_presence_of(:user) }
  end

  context 'associations' do
    it { should belong_to(:task) }
    it { should belong_to(:user) }
  end
end