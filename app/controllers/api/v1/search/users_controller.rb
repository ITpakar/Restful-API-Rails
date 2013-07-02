module Api
  module V1
    module Search
      class UsersController < Api::V1::SearchController
        
        def index
          # SOLR: Can't find query using instance variable?
          query = @query

          @users = User.search do
            keywords(query) do
              fields :full_name
              boost(5.0) { with(:follows_id, current_user.id) }
              boost(3.0) { with(:followers_id, current_user.id) }
            end
            without :full_name, nil
            paginate(page: @page, per_page: 10)
          end.results

          json = Jbuilder.encode do |json|
            json.data do |data|
              data.users do |info|
                info.array! @users do |user|
                  info.user_id user.id
                  info.full_name user.full_name
                  info.profile_picture_url user.profile_picture_url
                  info.is_following user.is_following?(current_user.id)
                  info.is_follower user.is_follower?(current_user.id)
                end
              end
            end
            json.success true
          end

          render json: json, status: 200
        end

      end
    end
  end
end