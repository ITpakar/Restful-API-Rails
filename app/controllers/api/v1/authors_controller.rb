module Api
  module V1
    class AuthorsController < Api::BaseController

      before_filter :set_page_and_count
      before_filter :validate_author_object, only: [:show]
      
      def index
        @authors = Author.page(@page).per(@count).order('last_name ASC, first_name ASC')

        json = Response::Collection.new('author', @authors, { page: @page }).to_json

        render json: json, status: 200
      end

      def show
        author = Author.find(params[:id])
        @quotes = author.quotes.page(@page).per(@count).order('author_last_name ASC, author_first_name ASC, body ASC')

        json = Response::Collection.new('quote', @quotes, {current_user_id: current_user.id, page: @page}).to_json
        
        render json: json, status: 200
      end

      private

        def set_page_and_count
          @page = params[:page].present? ? params[:page] : 1
          @count = params[:count].present? ? params[:count] : 10
        end

        def ensure_params_id_exist
          return unless params[:id].blank?
          render json: { success: false, message: "Missing author_id parameter" }, status: 200
        end

        def check_existence_of_author
          return if Author.exists?(id: params[:id])
          render json: { success: false, message: "Author not found" }, status: 200
        end

        def validate_author_object
          ensure_params_id_exist || check_existence_of_author
        end

    end
  end
end
