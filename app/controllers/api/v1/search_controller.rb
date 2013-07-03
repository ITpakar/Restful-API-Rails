module Api
  module V1
    class SearchController < Api::BaseController
      before_filter :ensure_search_query_exists
      before_filter :initialize_search_parameters

      protected

        def ensure_search_query_exists
          return unless params[:q].blank?
          render json: { success: false, message: "Missing search query" }, status: 200
        end

        def initialize_search_parameters
          @query = params[:q].dup.downcase
          @page = params[:page]
          @page = 1 if @page.blank?
        end
    end
  end
end
