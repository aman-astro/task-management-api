require 'rails_helper'

describe Api::V1::UsersController, type: :controller do
  before do
    allow(controller).to receive(:authenticate_request).and_return(true)
    allow(UserMailer).to receive_message_chain(:reset_password_otp, :deliver_later)
  end

  let!(:user) { User.create!(name: 'Test User', email: 'user@example.com', password: 'password123') }

  describe 'GET #index' do
    it 'returns a list of users' do
      get :index
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['status']).to eq('success')
      expect(json['data'].first['id']).to eq(user.id)
    end
  end

  describe 'GET #show' do
    it 'returns a specific user' do
      get :show, params: { id: user.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['status']).to eq('success')
      expect(json['data']['id']).to eq(user.id)
    end
    it 'returns not found for invalid id' do
      get :show, params: { id: 0 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PUT #update' do
    before { allow(controller).to receive(:current_user).and_return(user) }
    it 'updates a user with valid params' do
      put :update, params: { id: user.id, user: { name: 'Updated Name' } }
      expect(response).to have_http_status(:ok)
      expect(user.reload.name).to eq('Updated Name')
    end
    it 'does not update a user with invalid params' do
      put :update, params: { id: user.id, user: { name: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE #destroy' do
    before { allow(controller).to receive(:current_user).and_return(user) }
    it 'deletes a user' do
      expect {
        delete :destroy, params: { id: user.id }
      }.to change(User, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #forgot_password' do
    it 'sends OTP if user exists' do
      post :forgot_password, params: { user_email: user.email }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('OTP sent to your email')
    end
    it 'returns not found if user does not exist' do
      post :forgot_password, params: { user_email: 'notfound@example.com' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #reset_password' do
    before { user.generate_reset_password_otp! }
    it 'resets password with valid OTP and matching passwords' do
      post :reset_password, params: {
        user_email: user.email,
        otp: user.reset_password_otp,
        new_password: 'newpassword123',
        confirm_new_password: 'newpassword123'
      }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Password has been reset successfully')
    end
    it 'returns error for invalid OTP' do
      post :reset_password, params: {
        user_email: user.email,
        otp: '000000',
        new_password: 'newpassword123',
        confirm_new_password: 'newpassword123'
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'returns error for mismatched passwords' do
      post :reset_password, params: {
        user_email: user.email,
        otp: user.reset_password_otp,
        new_password: 'newpassword123',
        confirm_new_password: 'wrongpassword'
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

end