module Api
  module V1
    class PostsController < Api::BaseController

      before_filter :ensure_params_post_exist, only: [:create]
      before_filter :validate_post_object, except: [:create, :editors_picks, :popular]

      def create
        post = current_user.posts.build(params[:post])
        post.save
        
        render json: Response::Object.new('post', post, {current_user_id: current_user.id, api_version: @api_version}).to_json, status: 200
      end

      def show
        json = Response::Object.new('post', instance_post, {current_user_id: current_user.id, api_version: @api_version}).to_json

        render json: json, status: 200
      end

      def flag
        instance_post.flag!
        
        render json: Response::Object.new('post', instance_post, {current_user_id: current_user.id, api_version: @api_version}).to_json, status: 200
      end

      def editors_picks
        @posts = Post.editors_picked.page(params[:page]).per(params[:count] || 10)

        json = Response::Collection.new('post', @posts, {current_user_id: current_user.id, page: params[:page], override: true, api_version: @api_version}).to_json

        render json: json, status: 200
      end

      def popular
        @posts = Post.popular.page(params[:page]).per(params[:count] || 10)

        json = Response::Collection.new('post', @posts, {current_user_id: current_user.id, page: params[:page], override: true, api_version: @api_version}).to_json

        render json: json, status: 200
      end

      def destroy
        instance_post.destroy

        render json: {success: true, data: {}}, status: 200
      end

      protected

        def instance_post
          @instance_post ||= Post.where(id: params[:id]).includes(:user, :likes).first
        end

        def ensure_params_id_exist
          return unless params[:id].blank?
          render json: { success: false, message: "Missing post_id parameter" }, status: 200
        end

        def check_existence_of_post
          return if Post.exists?(id: params[:id])
          render json: { success: false, message: "Post not found" }, status: 200
        end

        def validate_post_object
          ensure_params_id_exist || check_existence_of_post
        end

        def ensure_params_post_exist
          return unless params[:post].blank?
          render json: { success: false, message: "Missing post parameter" }, status: 200
        end

    end
  end
end