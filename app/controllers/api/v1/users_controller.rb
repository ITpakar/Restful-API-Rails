module Api
  module V1
    class UsersController < Api::BaseController
      
      before_filter :ensure_params_user_exist, only: [:email_check]
      skip_before_filter :validate_authentication_token, only: [:email_check]
      before_filter :validate_user_object, except: [:email_check, :requested_by, :feed, :suggested]

      def email_check
        json = {
          data: {
            email: params[:user][:email],
            user_exists?: User.exists?(email: params[:user][:email])
          },
          success: true
        }.to_json
        
        render json: json, status: 200
      end

      def show
        json = Response::Object.new('user', instance_user, {current_user_id: current_user.id}).to_json
        render json: json, status: 200
      end

      def feed
        hash_conditions = {page: params[:page], count: params[:count]}
        hash_conditions.reject!{ |k,v| v.blank? }

        @posts = current_user.authenticated_feed(hash_conditions)

        json = Response::Collection.new('post', @posts, {current_user_id: current_user.id, page: params[:page]}).to_json

        render json: json, status: 200
      end

      def suggested
        page = params[:page] || 1
        count = params[:count] || 10
        @users = User.active.suggested.page(page).per(count).order("users.email = 'info@quotiful.com' DESC, users.updated_at DESC")

        json = Response::Collection.new('user', @users, {current_user_id: current_user.id, page: params[:page]}).to_json

        render json: json, status: 200
      end

      def follows
        @users = instance_user.followed_by_self.includes(:follows, :followers)

        json = Response::Collection.new('user', @users, { current_user_id: current_user.id, relative_user_id: instance_user.id }).to_json
        
        render json: json, status: 200
      end

      def followed_by
        @users = instance_user.followed_by_users.includes(:follows, :followers)

        json = Response::Collection.new('user', @users, { current_user_id: current_user.id, relative_user_id: instance_user.id }).to_json

        render json: json, status: 200
      end

      def requested_by
        @users = current_user.requested_by_users

        json = Response::Collection.new('user', @users, { current_user_id: current_user.id, relative_user_id: instance_user.id }).to_json

        render json: json, status: 200
      end

      def spam
        instance_user.is_spammer!

        json = Response::Object.new('user', instance_user, {current_user_id: current_user.id}).to_json
        
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