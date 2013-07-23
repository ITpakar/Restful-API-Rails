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
          
          json = Jbuilder.encode do |json|
            json.data do |data|
              data.tags @tags, :name, :posts_count
              data.page @page
            end
            json.success true
          end

          render json: json, status: 200
        end

      end
    end
  end
end