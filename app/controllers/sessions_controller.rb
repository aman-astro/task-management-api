# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_authenticity_token
  
  # Tell Devise this controller handles User model
  def resource_name
    :user
  end

  def resource_class
    User
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  # POST /users/sign_in (Login)
  def create
    user = User.find_by(email: params[:user][:email])
    
    if user&.valid_password?(params[:user][:password])
      sign_in(user)
      render json: {
        status: 'success',
        message: 'Logged in successfully',
        data: UserSerializer.new(user)
      }, status: :ok
    else
      render json: {
        status: 'error',
        message: 'Invalid email or password'
      }, status: :unauthorized
    end
  end

  # DELETE /users/sign_out (Logout)
  def destroy
    if current_user
      sign_out(current_user)
      render json: {
        status: 'success',
        message: 'Logged out successfully'
      }, status: :ok
    else
      render json: {
        status: 'error',
        message: 'No active session found'
      }, status: :unauthorized
    end
  end

  private

  def respond_with(resource, _opts = {})
    render json: {
      status: 'success',
      message: 'Logged in successfully',
      data: UserSerializer.new(resource)
    }, status: :ok
  end

  def respond_to_on_destroy
    render json: {
      status: 'success',
      message: 'Logged out successfully'
    }, status: :ok
  end
end
