module Api
  module V1
    class SessionsController < Api::BaseController
      
      skip_before_filter :validate_authentication_token, except: [:destroy]
      before_filter :ensure_params_user_exist, only: [:create]
     
      def create
        user = User.find_for_database_authentication(email: params[:user][:email])
        return invalid_login_attempt unless user
     
        if user.valid_password?(params[:user][:password])
          # sign_in(:user, user) unless signed_in?
          user.using_this_device(params[:device_token])
          json = Response::Object.new('user', user, {current_user_id: user.id}).to_json
          render json: json, status: 200
          return
        end
        
        invalid_login_attempt(user)
      end
      
      def destroy
        # sign_out(current_user) if signed_in?
        Device.signs_out_in(params[:device_token])
        render json: { success: true }, status: 200
      end
     
      protected
       
        def invalid_login_attempt(user)
          warden.custom_failure!
          message = user.has_password? ? "Error with your email or password" : "Please try signing in using Facebook"
          render json: { success: false, message: message }, status: 200
        end

    end
  end
end