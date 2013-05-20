module Api
  module V1
    class UsersController < Api::BaseController
      
      before_filter :ensure_params_user_exist, only: [:email_check]
      before_filter :validate_authentication_token, except: [:email_check]
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
                info.user post.user, :id, :full_name, :profile_picture
              end  
            end
          end
          json.success true
        end

        render json: json, status: 200
      end

      def follows
        json = Jbuilder.encode do |json|
          json.data do |data|
            data.users instance_user.followed_by_self, :full_name, :profile_picture, :id
          end
          json.success true
        end

        render json: json, status: 200
      end

      def followed_by
        json = Jbuilder.encode do |json|
          json.data do |data|
            data.users instance_user.followed_by_users, :full_name, :profile_picture, :id
          end
          json.success true
        end

        render json: json, status: 200
      end

      def requested_by
        json = Jbuilder.encode do |json|
          json.data do |data|
            data.users current_user.requested_by_users, :full_name, :profile_picture, :id
          end
          json.success true
        end

        render json: json, status: 200
      end

      def relationship
        json =  case request.method
                when "GET" then process_get
                when "POST" then process_post
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
            data.user instance_user, :full_name, :bio, :website, :follows_count, :followed_by_count, :id, :posts_count, :profile_picture
            
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

        def process_get
          as_follower = Relationship.find_by_user_id_and_follower_id(instance_user.id, current_user.id)
          as_followed_by = Relationship.find_by_user_id_and_follower_id(current_user.id, instance_user.id)

          json = Jbuilder.encode do |json|
            json.data do |data|
              data.outgoing_status as_follower.try(:status)
              data.incoming_status as_followed_by.try(:status)
            end
            json.success true
          end
          
          return json
        end

        def process_post
          as_follower = Relationship.find_or_initialize_by_user_id_and_follower_id(user_id: instance_user.id, follower_id: current_user.id)
          as_followed_by = Relationship.find_or_initialize_by_user_id_and_follower_id(user_id: current_user.id, follower_id: instance_user.id)

          if "follow".eql?(params[:status])
            as_follower.follow!
          elsif "approve".eql?(params[:status])
            as_followed_by.approve!
          elsif "block".eql?(params[:status])
            as_followed_by.block!
          elsif %(deny unblock).include?(params[:status])
            as_followed_by.deny!
          elsif "unfollow".eql?(params[:status])
            as_follower.unfollow!
          end

          as_follower = as_follower.new_record? ? nil : as_follower
          as_followed_by = as_followed_by.new_record? ? nil : as_followed_by

          json = Jbuilder.encode do |json|
            json.data do |data|
              data.outgoing_status as_follower.try(:status)
              data.incoming_status as_followed_by.try(:status)
            end
            json.success true
          end
          
          return json
        end

    end
  end
end