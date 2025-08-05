require 'rails_helper'

describe Api::V1::CommentsController, type: :controller do
  let(:user) { User.create!(name: 'Comment Owner', email: 'owner3@example.com', password: 'password123') }
  let(:other_user) { User.create!(name: 'Other User', email: 'other3@example.com', password: 'password123') }
  let!(:project) { Project.create!(title: 'Project', user: user) }
  let!(:task) { Task.create!(title: 'Task', project: project) }
  let!(:comment) { Comment.create!(content: 'A comment', task: task, user: user) }

  before do
    allow(controller).to receive(:authenticate_request).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #by_task' do
    it 'returns comments for the task' do
      get :by_task, params: { task_id: task.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data'].first['id']).to eq(comment.id)
    end
    it 'returns not found for task not owned by user' do
      other_project = Project.create!(title: 'Other Project', user: other_user)
      other_task = Task.create!(title: 'Other Task', project: other_project)
      get :by_task, params: { task_id: other_task.id }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #by_user' do
    it 'returns comments by the user for current_user projects' do
      get :by_user, params: { user_id: user.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data'].map { |c| c['id'] }).to include(comment.id)
    end
  end

  describe 'GET #show' do
    it 'returns a specific comment' do
      get :show, params: { id: comment.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(comment.id)
    end
    it 'returns not found for comment not owned by user' do
      other_project = Project.create!(title: 'Other Project', user: other_user)
      other_task = Task.create!(title: 'Other Task', project: other_project)
      other_comment = Comment.create!(content: 'Other comment', task: other_task, user: other_user)
      get :show, params: { id: other_comment.id }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    it 'creates a comment with valid params' do
      expect {
        post :create, params: { comment: { content: 'New comment', task_id: task.id } }
      }.to change(Comment, :count).by(1)
      expect(response).to have_http_status(:created)
    end
    it 'does not create a comment with invalid params' do
      expect {
        post :create, params: { comment: { content: '', task_id: task.id } }
      }.not_to change(Comment, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'returns not found for task not owned by user' do
      other_project = Project.create!(title: 'Other Project', user: other_user)
      other_task = Task.create!(title: 'Other Task', project: other_project)
      expect {
        post :create, params: { comment: { content: 'Hacked', task_id: other_task.id } }
      }.not_to change(Comment, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PUT #update' do
    it 'updates a comment with valid params' do
      put :update, params: { id: comment.id, comment: { content: 'Updated comment' } }
      expect(response).to have_http_status(:ok)
      expect(comment.reload.content).to eq('Updated comment')
    end
    it 'does not update a comment with invalid params' do
      put :update, params: { id: comment.id, comment: { content: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'returns not found for comment not owned by user' do
      other_project = Project.create!(title: 'Other Project', user: other_user)
      other_task = Task.create!(title: 'Other Task', project: other_project)
      other_comment = Comment.create!(content: 'Other comment', task: other_task, user: other_user)
      put :update, params: { id: other_comment.id, comment: { content: 'Hacked' } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes a comment' do
      expect {
        delete :destroy, params: { id: comment.id }
      }.to change(Comment, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
    it 'returns not found for comment not owned by user' do
      other_project = Project.create!(title: 'Other Project', user: other_user)
      other_task = Task.create!(title: 'Other Task', project: other_project)
      other_comment = Comment.create!(content: 'Other comment', task: other_task, user: other_user)
      delete :destroy, params: { id: other_comment.id }
      expect(response).to have_http_status(:not_found)
    end
  end
end