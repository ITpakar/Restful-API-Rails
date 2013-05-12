module Api
  class BaseController < ApplicationController
    include ApiVersions::SimplifyFormat
    include ActionController::MimeResponds
    
    skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/vnd.quotiful+json;version=1' }

    respond_to :json

    protected

      def current_user
        if params[:authentication_key].present?
          @current_user ||= User.find_by_authentication_token(params[:authentication_key])
          if @current_user.present?
            sign_in(:user, @current_user)
            return @current_user
          end
        end
      end

      def ensure_authentication_key_exist
        return unless params[:authentication_key].blank?
        render json: { success: false, message: "Missing authentication_key parameter" }, status: 200
      end

      def check_validity_of_authentication_key
        return if current_user.present?
        render json: { success: false, message: "Invalid authentication_key parameter" }, status: 200
      end

      def validate_authentication_key
        ensure_authentication_key_exist || check_validity_of_authentication_key
      end
    
      def ensure_params_user_exist
        return unless params[:user].blank?
        render json: { success: false, message: "Missing user parameter" }, status: 200
      end
  end
end