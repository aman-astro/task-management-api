class Api::V1::BaseController < ApplicationController
  respond_to :json
  skip_before_action :verify_authenticity_token

  protected

  def render_success(data, message = 'Success', status = :ok)
    render json: {
      status: 'success',
      message: message,
      data: data
    }, status: status
  end

  def render_error(message, errors = [], status = :unprocessable_entity)
    render json: {
      status: 'error',
      message: message,
      errors: errors
    }, status: status
  end

  def render_not_found(message = 'Resource not found')
    render json: {
      status: 'error',
      message: message
    }, status: :not_found
  end

  def render_unauthorized(message = 'Unauthorized access')
    render json: {
      status: 'error',
      message: message
    }, status: :unauthorized
  end
end