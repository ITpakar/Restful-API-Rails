module Api
  module V1
    class RegistrationsController < Api::BaseController
      
      def create
        user_params = params[:user].dup
        

        if user_params[:facebook_id].present?
          generated_password = Devise.friendly_token.first(6)
          user_params.update(password: generated_password, password_confirmation: generated_password)
        end

        user = User.new(user_params)

        if user.save
          render json: user.to_builder.target!, status: 201
          return
        else
          warden.custom_failure!
          render json: user.to_builder.target!, status: 422
        end
      end

    end
  end
end