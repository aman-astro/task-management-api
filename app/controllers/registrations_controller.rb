# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  include JsonResponse
  
  respond_to :json
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_request
  before_action :configure_sign_up_params, only: [:create]
  
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

  # POST /users (Signup)
  def create
    build_resource(sign_up_params)

    if resource.save
      sign_up(resource_name, resource)
      render_success(UserSerializer.new(resource), 'User created successfully', :created)
    else
      render_error('User creation failed', resource.errors.full_messages)
    end
  end

  protected

  # Permit the name parameter for sign up
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render_success(UserSerializer.new(resource), 'User created successfully', :created)
    else
      render_error('User creation failed', resource.errors.full_messages)
    end
  end
end
