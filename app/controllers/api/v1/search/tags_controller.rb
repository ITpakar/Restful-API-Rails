module Api
  module V1
    module Search
      class TagsController < Api::V1::SearchController
        
        def index
          query = @query.delete('#')
          
          @tags = Tag.search do
            fulltext query
            paginate(page: @page, per_page: 10)
          end.results
          
          json = Jbuilder.encode do |json|
            json.data do |data|
              data.tags @tags, :name, :posts_count
            end
            json.success true
          end

          render json: json, status: 200
        end

      end
    end
  end
end