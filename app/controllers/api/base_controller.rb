class Api::BaseController < ApplicationController
  include ApiVersions::SimplifyFormat
  include ActionController::MimeResponds
  
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/vnd.quotiful+json;version=1' }

  respond_to :json
end
