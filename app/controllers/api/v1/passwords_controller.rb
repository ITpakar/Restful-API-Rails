module Api
  module V1
    class PasswordsController < Api::BaseController
      
      before_filter :ensure_params_user_exist
      skip_before_filter :validate_authentication_token, only: [:create]

      def create
        if User.exists?(email: params[:user][:email])
          @user = User.where(email: params[:user][:email]).first
          ::Users::Mailer.reset_password_instructions(@user.id).deliver
          render json: { success: true, message: "Reset password instruction sent to email" }, status: 200
        else
          render json: { success: false, message: "User does not exist" }, status: 200
        end
      end

    end
  end
end