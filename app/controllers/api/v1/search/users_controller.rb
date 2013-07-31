module Api
  module V1
    module Search
      class UsersController < Api::V1::SearchController
        
        def index
          # SOLR: Can't find query using instance variable?
          query = @query
          page = @page
          count = @count

          @users = User.search do
            keywords(query) do
              fields :full_name
              boost(5.0) { with(:follows_id, current_user.id) }
              boost(3.0) { with(:followers_id, current_user.id) }
            end
            without :full_name, nil
            paginate(page: page, per_page: count)
          end.results

          json = Response::Collection.new('user', @users, { current_user_id: current_user.id, page: @page }).to_json

          render json: json, status: 200
        end

        def facebook
          facebook_ids = params[:ids].dup.to_s

          @users = User.where(facebook_id: facebook_ids.split(',')).order("full_name ASC").page(@page).per(10)

          json = Response::Collection.new('user', @users, { current_user_id: current_user.id, page: @page }).to_json

          render json: json, status: 200
        end

      end
    end
  end
end