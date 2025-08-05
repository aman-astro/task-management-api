require 'rails_helper'

describe Project, type: :model do
  subject { Project.new(title: "Unique Title", user: User.new(name: "Test", email: "test@example.com", password: "password123")) }

  context 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:user) }
    it { should validate_uniqueness_of(:title).scoped_to(:user_id) }
  end

  context 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:tasks).dependent(:destroy) }
  end
end