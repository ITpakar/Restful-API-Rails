module Api
  module V1
    module Search
      class AuthorsController < Api::V1::SearchController
        
        def index
          # SOLR: Can't find query using instance variable?
          query = @query

          @authors = Author.search do
            fulltext query
            paginate(page: @page, per_page: 10)
          end.results

          json = Jbuilder.encode do |json|
            json.data do |data|
              data.authors @authors, :id, :name
              data.page @page
            end
            json.success true
          end

          render json: json, status: 200
        end

        def random
          @author = Author.order('rand()').first

          json = Jbuilder.encode do |data|
            data.author do |author|
              author.(@author, :id, :name)
            end
          end

          render json: json, status: 200
        end

      end
    end
  end
end
