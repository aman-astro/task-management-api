require 'rails_helper'

describe Api::V1::ProjectsController, type: :controller do
  let(:user) { User.create!(name: 'Project Owner', email: 'owner@example.com', password: 'password123') }
  let(:other_user) { User.create!(name: 'Other User', email: 'other@example.com', password: 'password123') }
  let!(:project) { Project.create!(title: 'Test Project', user: user) }

  before do
    allow(controller).to receive(:authenticate_request).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'returns current_user projects' do
      get :index
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['status']).to eq('success')
      expect(json['data'].first['id']).to eq(project.id)
    end
  end

  describe 'GET #show' do
    it 'returns a specific project' do
      get :show, params: { id: project.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(project.id)
    end
    it 'returns not found for project not owned by user' do
      other_project = Project.create!(title: 'Other Project', user: other_user)
      get :show, params: { id: other_project.id }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    it 'creates a project with valid params' do
      expect {
        post :create, params: { project: { title: 'New Project', description: 'desc' } }
      }.to change(Project, :count).by(1)
      expect(response).to have_http_status(:created)
    end
    it 'does not create a project with invalid params' do
      expect {
        post :create, params: { project: { title: '' } }
      }.not_to change(Project, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT #update' do
    it 'updates a project with valid params' do
      put :update, params: { id: project.id, project: { title: 'Updated Title' } }
      expect(response).to have_http_status(:ok)
      expect(project.reload.title).to eq('Updated Title')
    end
    it 'does not update a project with invalid params' do
      put :update, params: { id: project.id, project: { title: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'returns not found for project not owned by user' do
      other_project = Project.create!(title: 'Other Project', user: other_user)
      put :update, params: { id: other_project.id, project: { title: 'Hacked' } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes a project' do
      expect {
        delete :destroy, params: { id: project.id }
      }.to change(Project, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
    it 'returns not found for project not owned by user' do
      other_project = Project.create!(title: 'Other Project', user: other_user)
      delete :destroy, params: { id: other_project.id }
      expect(response).to have_http_status(:not_found)
    end
  end
end