module Api
  module V1
    class PostsController < Api::BaseController

      before_filter :ensure_params_post_exist, only: [:create]
      before_filter :validate_post_object, except: [:create, :editors_picks, :popular_quotes]

      def create
        post = current_user.posts.build(params[:post])
        post.save
        
        render json: post.to_builder.target!, status: 200
      end

      def show
        json = Jbuilder.encode do |json|
          json.data do |data|
            data.post do |post|
              post.caption instance_post.caption
              post.editors_pick instance_post.editors_pick
              post.post_id instance_post.id
              post.likes_count instance_post.likes_count
              post.quote instance_post.quote
              post.quote_image_url instance_post.quote_image_url
              post.posted_at instance_post.created_at.to_i
              post.user_liked instance_post.liked_by?(current_user.id)
              post.set! :user do
                post.set! :user_id, instance_post.user_id
                post.set! :full_name, instance_post.user.full_name
                post.set! :profile_picture_url, instance_post.user.profile_picture_url
              end
            end
          end
          json.success true
        end

        render json: json, status: 200
      end

      def editors_picks
        options = {
          start_date: params[:start_date],
          end_date: params[:end_date],
          min_id: params[:min_id],
          max_id: params[:max_id],
          count: params[:count]
        }
        options.reject!{ |k,v| v.blank? }

        @posts = Post.editors_picked(options)

        json = posts_collection

        render json: json, status: 200
      end

      def popular
        options = {
          start_date: params[:start_date],
          end_date: params[:end_date],
          min_id: params[:min_id],
          max_id: params[:max_id],
          count: params[:count]
        }
        options.reject!{ |k,v| v.blank? }

        @posts = Post.popular(options)

        json = posts_collection

        render json: json, status: 200
      end

      protected

        def posts_collection
          Jbuilder.encode do |json|
            json.data do |data|
              data.posts do |posts|
                posts.array! @posts do |post|
                  posts.caption post.caption
                  posts.editors_pick post.editors_pick
                  posts.likes_count post.likes_count
                  posts.quote post.quote
                  posts.quote_image_url post.quote_image_url
                  posts.post_id post.id
                  posts.posted_at post.created_at.to_i
                  posts.user_liked post.liked_by?(current_user.id)
                  posts.set! :user do
                    posts.set! :user_id, post.user_id 
                    posts.set! :full_name, post.user.full_name
                    posts.set! :profile_picture_url, post.user.profile_picture_url
                  end
                end
              end
            end
            json.success true
          end
        end

        def instance_post
          @instance_post ||= Post.where(id: params[:id]).includes?(:user, :likes).first
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