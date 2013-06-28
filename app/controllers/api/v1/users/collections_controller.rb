module Api
  module V1
    module Users
      class CollectionsController < Api::V1::UsersController

        def index
          hash_conditions = {page: params[:page], count: params[:count]}
          hash_conditions.reject!{ |k,v| v.blank? }

          json = Jbuilder.encode do |json|
            json.data do |data|
              data.posts do |info|
                info.array! instance_user.collected_posts.order('posts.created_at DESC').page(params[:page]).per(params[:count] || 10) do |post|
                  info.caption post.caption
                  info.editors_pick post.editors_pick
                  info.post_id post.id
                  info.likes_count post.likes_count
                  info.quote post.quote
                  info.quote_image_url post.quote_image_url
                  info.posted_at post.created_at.to_i
                  info.user_liked post.liked_by?(current_user.id)
                  info.set! :user do
                    info.set! :user_id, post.user_id
                    info.set! :full_name, post.user.full_name
                    info.set! :profile_picture, post.user.profile_picture.try(:url)
                  end
                end  
              end
              data.page (params[:page] || 1)
            end
            json.success true
          end

          render json: json, status: 200
        end

        def create
          if params[:post_id].blank?
            render json: { success: false, message: "Missing post_id parameter" }, status: 200
            return
          end

          unless Post.exists?(id: params[:post_id])
            render json: { success: false, message: "Post not found" }, status: 200
            return
          end

          Collection.find_or_create_by_user_id_and_post_id(user_id: current_user.id, post_id: params[:post_id])
          render json: { success: true }, status: 200
        end

        def destroy
          if params[:id].blank?
            render json: { success: false, message: "Missing id parameter" }, status: 200
            return
          end

          unless Post.exists?(id: params[:id])
            render json: { success: false, message: "Post not found" }, status: 200
            return
          end

          collection = Collection.find_or_initialize_by_user_id_and_post_id(user_id: current_user.id, post_id: params[:id])
          collection.destroy unless collection.new_record?

          render json: { success: true }, status: 200
        end

        protected

          def ensure_params_id_exist
            return unless params[:user_id].blank?
            render json: { success: false, message: "Missing user_id parameter" }, status: 200
          end

          def check_existence_of_user
            return if User.exists?(id: params[:user_id])
            render json: { success: false, message: "User not found" }, status: 200
          end

          def instance_user
            @instance_user ||= User.find(params[:user_id])
          end

      end
    end
  end
end