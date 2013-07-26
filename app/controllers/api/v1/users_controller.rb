module Api
  module V1
    class UsersController < Api::BaseController
      
      before_filter :ensure_params_user_exist, only: [:email_check]
      skip_before_filter :validate_authentication_token, only: [:email_check]
      before_filter :validate_user_object, except: [:email_check, :requested_by, :feed]

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

      def show
        render json: instance_user.to_builder(with_notifications: is_current_user?, is_current_user: is_current_user?, current_user_id: current_user.id).target!, status: 200
      end

      def feed
        hash_conditions = {page: params[:page], count: params[:count]}
        hash_conditions.reject!{ |k,v| v.blank? }

        @posts = current_user.authenticated_feed(hash_conditions)

        json = Response::Collection.new('post', @posts, {current_user_id: current_user.id, page: params[:page]}).to_json

        render json: json, status: 200
      end

      def follows
        @users = instance_user.followed_by_self.includes(:follows, :followers)

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.users do |info|
              info.array! @users do |user|
                info.user_id user.id
                info.full_name user.full_name
                info.profile_picture_url user.profile_picture_url
                info.following_me current_user.following_me?(user.id)
                info.am_follower current_user.am_follower?(user.id)
                info.following_date current_user.following_date(user.id)
                info.follower_date current_user.follower_date(user.id)
              end
            end
          end
          json.success true
        end

        render json: json, status: 200
      end

      def followed_by
        @users = instance_user.followed_by_users.includes(:follows, :followers)

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.users do |info|
              info.array! @users do |user|
                info.user_id user.id
                info.full_name user.full_name
                info.profile_picture_url user.profile_picture_url
                info.following_me current_user.following_me?(user.id)
                info.am_follower current_user.am_follower?(user.id)
                info.following_date current_user.following_date(user.id)
                info.follower_date current_user.follower_date(user.id)
              end
            end
          end
          json.success true
        end

        render json: json, status: 200
      end

      def requested_by
        @users = current_user.requested_by_users

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.users do |info|
              info.array! @users do |user|
                info.user_id user.id
                info.full_name user.full_name
                info.profile_picture_url user.profile_picture_url
              end
            end
          end
          json.success true
        end

        render json: json, status: 200
      end

      def recent
        @posts = instance_user.posts.order('posts.created_at DESC').page(params[:page]).per(params[:count] || 10)

        json = Response::Collection.new('post', @posts, {current_user_id: current_user.id, page: params[:page], instance_user_id: instance_user.id}).to_json

        render json: json, status: 200
      end

      protected

        def is_current_user?
          instance_user.id == current_user.id
        end

        def ensure_params_id_exist
          return unless params[:id].blank?
          render json: { success: false, message: "Missing user_id parameter" }, status: 200
        end

        def check_existence_of_user
          return if User.exists?(id: params[:id])
          render json: { success: false, message: "User not found" }, status: 200
        end

        def instance_user
          @instance_user ||= User.find(params[:id])
        end

        def validate_user_object
          ensure_params_id_exist || check_existence_of_user
        end

    end
  end
end