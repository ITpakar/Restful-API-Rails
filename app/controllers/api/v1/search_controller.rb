module Api
  module V1
    class SearchController < Api::BaseController
      before_filter :ensure_search_query_exists

      protected

        def ensure_search_query_exists
          return unless params[:q].blank?
          render json: { success: false, message: "Missing search query" }, status: 200
        end
    end
  end
end
