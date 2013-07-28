module Api
  module V1
    class ActivitiesController < Api::BaseController
      
      def index
        current_user.activities.unread.update_all(viewed: true)
        count = params[:count].present? ? params[:count] : 20
        activities = current_user.activities.order("created_at DESC").page(params[:page]).per(count)

        json = Response::Collection.new('activity', activities, { page: params[:page] }).to_json

        render json: json, status: 200
      end

    end
  end
end