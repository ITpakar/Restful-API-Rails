module Api
  module V1
    class PostsController < Api::BaseController

      before_filter :ensure_params_post_exist, only: [:create]
      before_filter :validate_post_object, except: [:create, :editors_picks, :popular]

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
              post.description instance_post.description
              post.editors_pick instance_post.editors_pick
              post.post_id instance_post.id
              post.likes_count instance_post.likes_count
              post.quote instance_post.quote
              post.author_name instance_post.author_name
              post.quote_image_url instance_post.quote_image_url
              post.posted_at instance_post.created_at.to_i
              post.user_liked instance_post.liked_by?(current_user.id)
              post.web_url post_url(instance_post.created_at.to_i)
              post.background_image_url instance_post.background_image_url
              post.quote_attr instance_post.quote_attr
              post.author_attr instance_post.author_attr
              post.quotebox_attr instance_post.quotebox_attr
              post.origin_id instance_post.origin_id
              post.tagged_users instance_post.tagged_users
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

      def flag
        instance_post.flag!
        
        render json: instance_post.to_builder(flagged_details: true).target!, status: 200
      end

      def editors_picks
        @posts = Post.editors_picked.page(params[:page]).per(params[:count] || 10)

        json = posts_collection

        render json: json, status: 200
      end

      def popular
        @posts = Post.popular.page(params[:page]).per(params[:count] || 10)

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
                  posts.description post.description
                  posts.editors_pick post.editors_pick
                  posts.likes_count post.likes_count
                  posts.quote post.quote
                  posts.quote_image_url post.quote_image_url
                  posts.post_id post.id
                  posts.posted_at post.created_at.to_i
                  posts.user_liked post.liked_by?(current_user.id)
                  posts.web_url post_url(post.created_at.to_i)
                  posts.tagged_users post.tagged_users
                  posts.set! :user do
                    posts.set! :user_id, post.user_id 
                    posts.set! :full_name, post.user.full_name
                    posts.set! :profile_picture_url, post.user.profile_picture_url
                  end
                end
              end
              data.page (params[:page] || 1)
            end
            json.success true
          end
        end

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