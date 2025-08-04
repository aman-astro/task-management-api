# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  before_action :configure_sign_up_params, only: [:create]

  # POST /users (Signup)
  def create
    build_resource(sign_up_params)

    if resource.save
      sign_up(resource_name, resource)
      render json: {
        status: 'success',
        message: 'User created successfully',
        data: UserSerializer.new(resource)
      }, status: :created
    else
      render json: {
        status: 'error',
        message: 'User creation failed',
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  protected

  # Permit the name parameter for sign up
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: 'success',
        message: 'User created successfully',
        data: UserSerializer.new(resource)
      }, status: :created
    else
      render json: {
        status: 'error',
        message: 'User creation failed',
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end
