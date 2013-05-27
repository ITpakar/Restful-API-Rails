module Api
  module V1
    class SessionsController < Api::BaseController
      
      skip_before_filter :validate_authentication_token, except: [:destroy]
      before_filter :ensure_params_user_exist, only: [:create]
     
      def create
        user = User.find_for_database_authentication(email: params[:user][:email])
        return invalid_login_attempt unless user
     
        if user.valid_password?(params[:user][:password])
          sign_in(:user, user)
          render json: user.to_builder.target!, status: 200
          return
        end
        
        invalid_login_attempt
      end
      
      def destroy
        sign_out(current_user) if signed_in?
        render json: { success: true }, status: 200
      end
     
      protected
       
        def invalid_login_attempt
          warden.custom_failure!
          render json: { success: false, message: "Error with your email or password" }, status: 200
        end

    end
  end
end