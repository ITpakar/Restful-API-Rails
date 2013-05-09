class Api::BaseController < ApplicationController
  include ApiVersions::SimplifyFormat
  include ActionController::MimeResponds
  respond_to :json
end
