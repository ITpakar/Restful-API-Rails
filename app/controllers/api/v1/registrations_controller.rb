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
        [:author_name, :favorite_quote, :website].each do |key|
          user_params.reverse_update(key => params[:user][key]) if params[:user].has_key?(key)  
        end

        cond1 = true
        cond4 = false

        [:password, :password_confirmation].each do |key|
          cond1 &= user_params.has_key?(key)
          cond4 |= user_params.has_key?(key)
        end

        cond2 = (current_user.valid_password?(user_params[:current_password]) || !current_user.has_password?)
        cond3 = (user_params[:password] == user_params[:password_confirmation])
        cond4 |= user_params.has_key?(:current_password)

        user_params.update(has_password: true) if cond1 and cond2 and cond3

        if (cond1 and cond2 and cond3) or !cond4
          current_user.update_attributes(user_params)
          json = Response::Object.new('user', current_user.reload, {current_user_id: current_user.id}).to_json
          render json: json, status: 200
        else
          render json: { success: false, message: "Error with your password" }, status: 200
        end
      end

      protected

        def login_facebook_user(facebook_id)
          user = User.find_by_facebook_id(facebook_id)
          if user.present?
            return deactivated_user unless user.active?
            user.using_this_device(params[:device_token])

            json = Response::Object.new('user', user, {current_user_id: user.id}).to_json
            
            render json: json, status: 200
          end
        end

    end
  end
end