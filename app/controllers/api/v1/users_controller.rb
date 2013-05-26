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
        render json: instance_user.to_builder.target!, status: 200
      end

      def feed
        hash_conditions = {min_id: params[:min_id], max_id: params[:max_id], count: params[:count]}
        hash_conditions.reject!{ |k,v| v.blank? }

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.posts do |info|
              info.array! current_user.authenticated_feed(hash_conditions) do |post|
                info.caption post.caption
                info.editors_pick post.editors_pick
                info.post_id post.id
                info.likes_count post.likes_count
                info.quote post.quote
                info.quote_image post.quote_image
                info.user post.user, :id, :full_name
                info.set! :user do
                  info.set! :user_id, post.user_id
                  info.set! :full_name, post.user.full_name
                  info.set! :profile_picture, post.user.profile_picture.try(:url)
                end
              end  
            end
          end
          json.success true
        end

        render json: json, status: 200
      end

      def follows
        @users = instance_user.followed_by_self

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.users do |info|
              info.array! @users do |user|
                info.user_id user.id
                info.full_name user.full_name
                info.profile_picture user.profile_picture.try(:url)
              end
            end
          end
          json.success true
        end

        render json: json, status: 200
      end

      def followed_by
        @users = instance_user.followed_by_users

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.users do |info|
              info.array! @users do |user|
                info.user_id user.id
                info.full_name user.full_name
                info.profile_picture user.profile_picture.try(:url)
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
                info.profile_picture user.profile_picture.try(:url)
              end
            end
          end
          json.success true
        end

        render json: json, status: 200
      end

      def recent
        hash_conditions = {}
        hash_conditions.update(min_id: params[:min_id]) if params[:min_id].present?
        hash_conditions.update(max_id: params[:max_id]) if params[:max_id].present?
        hash_conditions.update(min_timestamp: params[:min_timestamp]) if params[:min_timestamp].present?
        hash_conditions.update(max_timestamp: params[:max_timestamp]) if params[:max_timestamp].present?
        hash_conditions.update(count: params[:count]) if params[:count].present?

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.posts do |info|
              info.array! instance_user.posts.order('posts.created_at DESC') do |post|
                info.caption post.caption
                info.editors_pick post.editors_pick
                info.post_id post.id
                info.likes_count post.likes_count
                info.quote post.quote
                info.quote_image post.quote_image
              end
            end
            data.user do |user|
              user.full_name instance_user.full_name
              user.bio instance_user.bio
              user.website instance_user.website
              user.follows_count instance_user.follows_count
              user.followed_by_count instance_user.followed_by_count
              user.user_id instance_user.id
              user.posts_count instance_user.posts_count
              user.profile_picture instance_user.profile_picture.try(:url)
            end
            
          end
          json.success true
        end

        render json: json, status: 200
      end

      protected

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