module Api
  module V1
    class RegistrationsController < Api::BaseController
      
      before_filter :ensure_params_user_exist
      skip_before_filter :validate_authentication_token, only: [:create]

      def create
        user_params = params[:user].dup

        if user_params[:facebook_id].present?
          return login_facebook_user(user_params[:facebook_id]) if User.exists?(facebook_id: user_params[:facebook_id])

          generated_password = Devise.friendly_token.first(8)
          user_params.update(password: generated_password, password_confirmation: generated_password)
        end

        user = User.new(user_params)

        if user_params[:facebook_id].present? and !User.exists?(facebook_id: params[:facebook_id]) and params[:fb_friend_ids].present?
          fb_friend_ids = params[:fb_friend_ids].dup.to_a

          friends = User.find_by_facebook_id(fb_friend_ids)
          raw_device_tokens = []
          friends.each do |friend|
            raw_device_tokens << friend.devices.map(&:device_token)
          end
          device_tokens = raw_device_tokens.flatten.uniq.compact

          device_tokens.each do |token|
            PushNotification.new(token, "#{like.user.full_name} joined from Facebook")
          end
        end

        if user.save
          user.using_this_device(params[:device_token])
          render json: user.to_builder(is_current_user: true).target!, status: 200
          return
        else
          warden.custom_failure!
          render json: user.to_builder.target!, status: 200
        end
      end

      def update
        user_params = params[:user].dup
        user_params.reject!{ |k,v| v.blank? }

        cond1 = [:current_password, :password, :password_confirmation].all? { |sym| user_params.keys.include?(sym) }
        cond2 = current_user.valid_password?(user_params[:current_password])
        cond3 = user_params[:password] == user_params[:password_confirmation]
        cond4 = [:current_password, :password, :password_confirmation].any? { |sym| user_params.keys.include?(sym) }

        if (cond1 and cond2 and cond3) or !cond4
          current_user.update_attributes(user_params)
          render json: current_user.to_builder(with_notifications: true, is_current_user: true).target!, status: 200
        else
          render json: { success: false, message: "Error with your password" }, status: 200
        end
      end

      protected

        def login_facebook_user(facebook_id)
          user = User.find_by_facebook_id(facebook_id)
          if user.present?
            # sign_in(:user, user)
            user.using_this_device(params[:device_token])
            render json: user.to_builder(is_current_user: true).target!, status: 200
          end
        end

    end
  end
end