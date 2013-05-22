module Api
  module V1
    module Posts
      class CommentsController < Api::BaseController
        
        before_filter :validate_post_object

        def index
          @comments = instance_post.comments.order("comments.created_at DESC")
          json = Jbuilder.encode do |json|
            json.data do |data|
              data.comments do |comments|
                comments.array! @comments do |comment|
                  comments.body comment.body
                  comments.post_id comment.commentable_id
                  comments.set! :user do
                    comments.set! :user_id, comment.user_id
                    comments.set! :full_name, comments.user.full_name
                    comments.set! :profile_picture, comments.user.profile_picture.try(:url)
                  end
                end
              end
            end
            json.success true
          end

          render json: json, status: 200
        end

        def create
          instance_post.comments.create(user_id: current_user.id, body: params[:body])
          json = {success: true, data: nil}.to_json

          render json: json, status: 200
        end

        def destroy
          comment = instance_post.comments.find(params[:id])
          comment.destroy if comment.present? and [instance_post.user_id, current_user.id].include?(comment.user_id)
          json = {success: true, data: nil}.to_json

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
