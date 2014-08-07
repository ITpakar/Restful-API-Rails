module Api
  module V1
    module Users
      class CollectionsController < Api::V1::UsersController

        def index
          hash_conditions = {page: params[:page], count: params[:count]}
          hash_conditions.reject!{ |k,v| v.blank? }
          page = params[:page] || 1
          count = params[:count] || 10

          @posts = instance_user.collected_posts.order('posts.created_at DESC').page(page).per(count)

          json = Response::Collection.new('post', @posts, {current_user_id: current_user.id, page: page, api_version: @api_version}).to_json

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