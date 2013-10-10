module Api
  module V1
    module Search
      class TagsController < Api::V1::SearchController
        
        def index
          # SOLR: Can't find query using instance variable?
          query = @query.delete('#')
          page = @page
          count = @count
          
          @tags = Tag.search do
            fulltext query
            paginate(page: page, per_page: count)
          end.results

          json = Response::Collection.new('tag', @tags, { current_user_id: current_user.id, page: @page, params: { q: @query } }).to_json
          
          render json: json, status: 200
        end

      end
    end
  end
end