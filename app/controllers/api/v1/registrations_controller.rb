module Api
  module V1
    class RegistrationsController < Api::BaseController
      
      before_filter :ensure_params_user_exist

      def create
        user_params = params[:user].dup

        if user_params[:facebook_id].present?
          return login_facebook_user(user_params[:facebook_id]) if User.exists?(facebook_id: user_params[:facebook_id])

          generated_password = Devise.friendly_token.first(8)
          user_params.update(password: generated_password, password_confirmation: generated_password)
        end

        user = User.new(user_params)

        if user.save
          render json: user.to_builder.target!, status: 200
          return
        else
          warden.custom_failure!
          render json: user.to_builder.target!, status: 200
        end
      end

      protected

        def login_facebook_user(facebook_id)
          user = User.find_by_facebook_id(facebook_id)
          if user.present?
            sign_in(:user, user)
            render json: user.to_builder.target!, status: 200
          end
        end

    end
  end
end