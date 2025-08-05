# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  include JsonResponse
  
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
      data = {
        auth_token: command.result,
        user: UserSerializer.new(user)
      }
      render_success(data, 'Logged in successfully')
    else
      render_unauthorized('Invalid email or password')
    end
  end

  # DELETE /logout
  def destroy
    # Since we're using stateless JWT, logout is handled client-side
    # by removing the token from client storage
    render_success(nil, 'Logged out successfully')
  end

  private

  def respond_with(resource, _opts = {})
    render_success(UserSerializer.new(resource), 'Logged in successfully')
  end

  def respond_to_on_destroy
    render_success(nil, 'Logged out successfully')
  end
end