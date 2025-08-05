require 'rails_helper'

describe Task, type: :model do
  subject { Task.new(title: "Unique Task", project: Project.new(title: "Project", user: User.new(name: "Test", email: "test@example.com", password: "password123"))) }

  context 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:project) }
    it { should validate_uniqueness_of(:title).scoped_to(:project_id) }
  end

  context 'associations' do
    it { should belong_to(:project) }
    it { should have_many(:comments).dependent(:destroy) }
  end

  context 'enums' do
    it { should define_enum_for(:status).with_values([:pending, :in_progress, :completed]) }
  end

  describe 'default scope' do
    it 'returns only non-deleted tasks' do
      project = Project.create!(title: 'Project', user: User.create!(name: 'Test', email: 'test2@example.com', password: 'password123'))
      task1 = Task.create!(title: 'Task 1', project: project)
      task2 = Task.create!(title: 'Task 2', project: project, deleted_at: Time.current)
      expect(Task.all).to include(task1)
      expect(Task.all).not_to include(task2)
    end
  end

  describe '#soft_delete' do
    it 'sets deleted_at timestamp' do
      project = Project.create!(title: 'Project', user: User.create!(name: 'Test', email: 'test3@example.com', password: 'password123'))
      task = Task.create!(title: 'Task', project: project)
      expect { task.soft_delete }.to change { task.deleted_at }.from(nil)
      expect(task).to be_deleted
    end
  end

  describe '#user' do
    it 'returns the user of the project' do
      user = User.create!(name: 'Test', email: 'test4@example.com', password: 'password123')
      project = Project.create!(title: 'Project', user: user)
      task = Task.create!(title: 'Task', project: project)
      expect(task.user).to eq(user)
    end
  end
end