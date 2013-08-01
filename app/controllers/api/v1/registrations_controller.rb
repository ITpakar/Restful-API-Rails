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
          user_params.update(password: generated_password, password_confirmation: generated_password, has_password: false)
        end

        if user_params[:facebook_id].present? and User.exists?(email: user_params[:email])
          user = User.find_by_email(user_params[:email])
          user.facebook_id = user_params[:facebook_id]
        else          
          user = User.new(user_params)
        end

        if user.save
          if user_params[:facebook_id].present? and params[:app_friend_ids].present?
            fb_friend_ids = params[:app_friend_ids].dup
            fb_friend_ids = fb_friend_ids.is_a?(String) ? fb_friend_ids.split(',') : fb_friend_ids.to_a

            friends = User.where(facebook_id: fb_friend_ids)
            Resque.enqueue(Jobs::Notify, :fb_friend_joins, friends.map(&:id), user.id)
          end

          user.using_this_device(params[:device_token])

          json = Response::Object.new('user', user, {current_user_id: user.id}).to_json
        else
          warden.custom_failure!
          json = Response::Object.new('user', user).to_json
        end

        return deactivated_user unless user.active?
        
        render json: json, status: 200
      end

      def update
        user_params = params[:user].dup
        user_params.reject!{ |k,v| v.blank? }
        user_params.reverse_update(author_name: params[:user][:author_name]) if params[:user].has_key?(:author_name)
        user_params.reverse_update(favorite_quote: params[:user][:favorite_quote]) if params[:user].has_key?(:favorite_quote)
        user_params.reverse_update(website: params[:user][:website]) if params[:user].has_key?(:website)

        cond1 = [:current_password, :password, :password_confirmation].all? { |sym| user_params.keys.include?(sym) }
        cond2 = current_user.valid_password?(user_params[:current_password])
        cond3 = user_params[:password] == user_params[:password_confirmation]
        cond4 = [:current_password, :password, :password_confirmation].any? { |sym| user_params.keys.include?(sym) }

        if (cond1 and cond2 and cond3) or !cond4
          current_user.update_attributes(user_params)
          json = Response::Object.new('user', current_user, {current_user_id: current_user.id}).to_json
          render json: json, status: 200
        else
          render json: { success: false, message: "Error with your password" }, status: 200
        end
      end

      protected

        def login_facebook_user(facebook_id)
          user = User.find_by_facebook_id(facebook_id)
          if user.present?
            user.using_this_device(params[:device_token])

            json = Response::Object.new('user', user, {current_user_id: user.id}).to_json
            
            render json: json, status: 200
          end
        end

    end
  end
end