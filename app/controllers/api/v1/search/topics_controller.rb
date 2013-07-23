module Api
  module V1
    module Search
      class TopicsController < Api::V1::SearchController
        
        def index
          query = @query

          @topics = Quote.search do
            keywords(query) do
              fields :name
            end

            paginate(page: @page, per_page: @count)
          end.results

          json = Jbuilder.encode do |json|
            json.data do |data|
              data.quotes @topics, :id, :name
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
