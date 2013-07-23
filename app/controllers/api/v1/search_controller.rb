module Api
  module V1
    class SearchController < Api::BaseController
      before_filter :ensure_search_query_exists
      before_filter :initialize_search_parameters

      protected

        def ensure_search_query_exists
          # NOTE: disabled for blank queries
          # return unless params[:q].nil?
          # render json: { success: false, message: "Missing search query" }, status: 200
        end

        def initialize_search_parameters
          @query = params[:q].to_s.dup.downcase
          @page = params[:page]
          @page = 1 if @page.blank?
          @count = params[:count]
          @count = 10 if @count.blank?
        end
    end
  end
end
