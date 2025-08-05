class Api::V1::BaseController < ApplicationController
  include JsonResponse
  
  respond_to :json
  skip_before_action :verify_authenticity_token
end