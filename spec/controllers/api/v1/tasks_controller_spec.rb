require 'rails_helper'

describe Api::V1::TasksController, type: :controller do
  let(:user) { User.create!(name: 'Task Owner', email: 'owner2@example.com', password: 'password123') }
  let(:other_user) { User.create!(name: 'Other User', email: 'other2@example.com', password: 'password123') }
  let!(:project) { Project.create!(title: 'Project', user: user) }
  let!(:task) { Task.create!(title: 'Task', project: project) }

  before do
    allow(controller).to receive(:authenticate_request).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'returns tasks for the project' do
      get :index, params: { project_id: project.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['tasks'].first['id']).to eq(task.id)
    end
    it 'returns not found for project not owned by user' do
      other_project = Project.create!(title: 'Other Project', user: other_user)
      get :index, params: { project_id: other_project.id }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #show' do
    it 'returns a specific task' do
      get :show, params: { id: task.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(task.id)
    end
    it 'returns not found for task not owned by user' do
      other_project = Project.create!(title: 'Other Project', user: other_user)
      other_task = Task.create!(title: 'Other Task', project: other_project)
      get :show, params: { id: other_task.id }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    it 'creates a task with valid params' do
      expect {
        post :create, params: { project_id: project.id, task: { title: 'New Task' } }
      }.to change(Task, :count).by(1)
      expect(response).to have_http_status(:created)
    end
    it 'does not create a task with invalid params' do
      expect {
        post :create, params: { project_id: project.id, task: { title: '' } }
      }.not_to change(Task, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'returns not found for project not owned by user' do
      other_project = Project.create!(title: 'Other Project', user: other_user)
      expect {
        post :create, params: { project_id: other_project.id, task: { title: 'Hacked' } }
      }.not_to change(Task, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PUT #update' do
    it 'updates a task with valid params' do
      put :update, params: { id: task.id, task: { title: 'Updated Task' } }
      expect(response).to have_http_status(:ok)
      expect(task.reload.title).to eq('Updated Task')
    end
    it 'does not update a task with invalid params' do
      put :update, params: { id: task.id, task: { title: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'returns not found for task not owned by user' do
      other_project = Project.create!(title: 'Other Project', user: other_user)
      other_task = Task.create!(title: 'Other Task', project: other_project)
      put :update, params: { id: other_task.id, task: { title: 'Hacked' } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'soft deletes a task' do
      delete :destroy, params: { id: task.id }
      expect(response).to have_http_status(:ok)
      expect(task.reload.deleted_at).not_to be_nil
    end
    it 'returns not found for task not owned by user' do
      other_project = Project.create!(title: 'Other Project', user: other_user)
      other_task = Task.create!(title: 'Other Task', project: other_project)
      delete :destroy, params: { id: other_task.id }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #all' do
    it 'returns all tasks for current_user' do
      get :all
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['tasks'].map { |t| t['id'] }).to include(task.id)
    end
  end
end