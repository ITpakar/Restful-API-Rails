module Api
  class BaseController < ApplicationController
    include ApiVersions::SimplifyFormat
    include ActionController::MimeResponds
    
    skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/vnd.quotiful+json;version=1' }
    before_filter :adjust_negative_id
    before_filter :validate_authentication_token

    respond_to :json

    protected

      def adjust_negative_id
        if params[:id].to_i < 0
          params.update(id: params[:id].to_i + 65_536)
        end
      end

      def deactivated_user
        render json: { success: false, signin_error: 102  }, status: 200
      end

      def current_user
        if params[:authentication_token].present?
          @current_user ||= User.find_by_authentication_token(params[:authentication_token])
          if @current_user.present?
            return @current_user
          end
        end
      end

      def ensure_authentication_token_exist
        return unless params[:authentication_token].blank?
        render json: { success: false, message: "Missing authentication_token parameter" }, status: 200
      end

      def check_validity_of_authentication_token
        return if current_user.present?
        render json: { success: false, message: "Invalid authentication_token parameter" }, status: 200
      end

      def is_current_user_active?
        return if current_user.present? and current_user.active?
        deactivated_user
      end

      def validate_authentication_token
        ensure_authentication_token_exist || check_validity_of_authentication_token || is_current_user_active?
      end
    
      def ensure_params_user_exist
        return unless params[:user].blank?
        render json: { success: false, message: "Missing user parameter" }, status: 200
      end
  end
end