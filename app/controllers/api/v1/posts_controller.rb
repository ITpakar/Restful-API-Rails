module Api
  module V1
    class PostsController < Api::BaseController

      before_filter :ensure_authentication_key_exist
      before_filter :ensure_params_post_exist

      def create
        post = current_user.posts.build(params[:post])
        
        if post.save
          render json: post.to_builder.target!, status: 200
          return
        else
          render json: post.to_builder.target!, status: 200
        end
      end

      protected

        def ensure_params_post_exist
          return unless params[:user].blank?
          render json: { success: false, message: "Missing post parameter" }, status: 200
        end
    end
  end
end