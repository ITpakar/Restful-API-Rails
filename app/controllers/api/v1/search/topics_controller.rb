module Api
  module V1
    module Search
      class TopicsController < Api::V1::SearchController
        
        def index
          query = @query
          page = @page
          count = @count

          @topics = Quote.search do
            keywords(query) do
              fields :name
            end

            paginate(page: page, per_page: count)
          end.results

          json = Response::Collection.new('quote', @topics, {current_user_id: current_user.id, page: @page}).to_json

          render json: json, status: 200
        end

      end
    end
  end
end
