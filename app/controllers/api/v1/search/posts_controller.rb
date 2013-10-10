module Api
  module V1
    module Search
      class PostsController < Api::V1::SearchController
        
        def index
          # SOLR: Can't find query using instance variable?
          user_id = params[:user_id]
          query = @query
          page = @page
          count = @count

          @posts = Post.search do
            keywords(query) do
              fields :caption, :quote, :author_name
            end

            if user_id.present?
              with :user_id, user_id 
            end

            paginate(page: page, per_page: count)
          end.results

          json = Response::Collection.new('post', @posts, {current_user_id: current_user.id, page: page, params: { q: @query }}).to_json

          render json: json, status: 200
        end
        
      end
    end
  end
end
