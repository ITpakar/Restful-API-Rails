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

          json = Jbuilder.encode do |json|
            json.data do |data|
              data.users do |info|
                info.array! @users do |user|
                  info.user_id user.id
                  info.full_name user.full_name
                  info.profile_picture_url user.profile_picture_url
                  info.following_me current_user.following_me?(user.id)
                  info.am_follower current_user.am_follower?(user.id)
                end
              end
              data.page @page
            end
            json.success true
          end

          render json: json, status: 200
        end

        def facebook
          facebook_ids = params[:ids].dup
          @users = User.where(facebook_id: facebook_ids).order("full_name ASC").page(@page).per(10)

          json = Jbuilder.encode do |json|
            json.data do |data|
              data.users do |info|
                info.array! @users do |user|
                  info.user_id user.id
                  info.facebook_id user.facebook_id
                  info.full_name user.full_name
                  info.profile_picture_url user.profile_picture_url
                  info.following_me current_user.following_me?(user.id)
                  info.am_follower current_user.am_follower?(user.id)
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