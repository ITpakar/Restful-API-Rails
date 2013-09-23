module Api
  module V1
    module Posts
      class LikesController < Api::BaseController
        
        before_filter :validate_post_object

        def index
          @users = instance_post.users_liked.order('likes.created_at DESC')

          json = Response::Collection.new('user', @users, { current_user_id: current_user.id }).to_json

          render json: json, status: 200
        end

        def create
          instance_post.likes.find_or_create_by_user_id(current_user.id)
          json = {success: true, data: {}}.to_json

          render json: json, status: 200
        end

        def destroy
          like = instance_post.likes.find_by_user_id(current_user.id)
          like.destroy if like.present?

          json = {success: true, data: {}}.to_json

          render json: json, status: 200
        end

        protected

          def instance_post
            @instance_post ||= Post.find(params[:post_id])
          end

          def ensure_params_id_exist
            return unless params[:post_id].blank?
            render json: { success: false, message: "Missing post_id parameter" }, status: 200
          end

          def check_existence_of_post
            return if Post.exists?(id: params[:post_id])
            render json: { success: false, message: "Post not found" }, status: 200
          end

          def validate_post_object
            ensure_params_id_exist || check_existence_of_post
          end

      end
    end
  end
end