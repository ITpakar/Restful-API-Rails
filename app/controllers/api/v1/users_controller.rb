module Api
  module V1
    class UsersController < Api::BaseController
      
      before_filter :ensure_params_user_exist

      def email_check
        user_exists = User.exists?(email: params[:user][:email])

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.email params[:user][:email]
            data.user_exists? user_exists
          end
          json.success true
        end
        
        render json: json, status: 200
      end

    end
  end
end