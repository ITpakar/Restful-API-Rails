module Api
  module V1
    module Search
      class PostsController < Api::V1::SearchController
        
        def index
          # SOLR: Can't find query using instance variable?
          user_id = params[:user_id]
          query = @query

          @posts = Post.search do
            keywords(query) do
              fields :caption, :quote, :author_name
            end

            if user_id.present?
              with :user_id, user_id 
            end

            paginate(page: @page, per_page: 10)
          end.results

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
                    posts.tagged_users post.tagged_users
                    posts.set! :user do
                      posts.set! :user_id, post.user_id 
                      posts.set! :full_name, post.user.full_name
                      posts.set! :profile_picture_url, post.user.profile_picture_url
                    end
                  end
                end
                data.page @page
              end
              json.success true
            end
          end

      end
    end
  end
end
