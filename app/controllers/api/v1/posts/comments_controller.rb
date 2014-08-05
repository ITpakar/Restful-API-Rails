module Api
  module V1
    module Posts
      class CommentsController < Api::BaseController
        
        before_filter :validate_post_object

        def index
          @comments = instance_post.comments.order("comments.created_at DESC")

          json = Response::Collection.new('comment', @comments, { current_user_id: current_user.id, api_version: @api_version }).to_json
          
          render json: json, status: 200
        end

        def create
          comment = instance_post.comments.build(params[:comment])
          comment.user_id = current_user.id
          comment.save

          poster_id = instance_post.user_id
          commenter_id = comment.user_id

          Resque.enqueue(Jobs::Notify, :comments_on_your_post, poster_id, commenter_id, {comment_id: comment.id, post_id: instance_post.id}) unless poster_id == commenter_id
          other_ids = instance_post.comments.map(&:user_id).uniq.compact - [commenter_id, poster_id]
          Resque.enqueue(Jobs::Notify, :comments_after_you, other_ids, commenter_id, {comment_id: comment.id, post_id: instance_post.id})
          
          json = Response::Object.new('comment', comment, { current_user_id: current_user.id, api_version: @api_version }).to_json 
          
          render json: json, status: 200
        end

        def destroy
          comment = instance_post.comments.find(params[:id])
          comment.destroy if comment.present? and [instance_post.user_id, current_user.id].include?(comment.user_id)

          render json: {success: true, data: {}}.to_json, status: 200
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
