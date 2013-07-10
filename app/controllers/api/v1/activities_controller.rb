module Api
  module V1
    class ActivitiesController < Api::BaseController
      
      def index
        activities = current_user.activities.order("created_at DESC").page(params[:page]).per(10)

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.posts do |posts|
              activities.array! activities do |activity|
                activities.body activity.body 
                activities.tagged_users activity.tagged_users
              end
            end
            data.page (params[:page] || 1)
          end
          json.success true
        end

        render json: json, status: 200
      end

    end
  end
end