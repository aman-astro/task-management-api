# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_request
  
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

  # POST /login
  def create
    email = params[:user][:email]
    password = params[:user][:password]
    command = AuthenticateUser.call(email, password)
    
    if command.success?
      user = User.find_by(email: email)
      render json: {
        status: 'success',
        message: 'Logged in successfully',
        auth_token: command.result,
        user: UserSerializer.new(user)
      }, status: :ok
    else
      render json: {
        status: 'error',
        message: 'Invalid email or password',
        errors: command.errors
      }, status: :unauthorized
    end
  end

  # DELETE /logout
  def destroy
    # Since we're using stateless JWT, logout is handled client-side
    # by removing the token from client storage
    render json: {
      status: 'success',
      message: 'Logged out successfully'
    }, status: :ok
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