module Api
  module V1
    class ActivitiesController < Api::BaseController
      
      def index
        current_user.activities.unread.update_all(viewed: true)
        activities = current_user.activities.order("created_at DESC").page(params[:page]).per(10)

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.info do |info|
              info.array! activities do |activity|
                info.body activity.body 
                info.identifier activity.custom_payloads.symbolize_keys[:identifier]
                info.timestamp activity.created_at.to_i
                info.details activity.tagged_details
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