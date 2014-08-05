module Api
  module V1
    module Search
      class AuthorsController < Api::V1::SearchController
        
        def index
          # SOLR: Can't find query using instance variable?
          query = @query
          page = @page
          count = @count

          @authors = Author.search do
            fulltext query
            paginate(page: page, per_page: count)
          end.results

          json = Response::Collection.new('author', @authors, { page: @page, params: { q: @query }, api_version: @api_version }).to_json

          render json: json, status: 200
        end

        def random
          @author = Author.order('random()').first

          json = Response::Object.new('author', @author).to_json

          render json: json, status: 200
        end

      end
    end
  end
end
