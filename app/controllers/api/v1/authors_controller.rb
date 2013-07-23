module Api
  module V1
    class AuthorsController < Api::BaseController

      before_filter :set_page_and_count
      before_filter :validate_author_object, only: [:show]
      
      def index
        @authors = Author.page(@page).per(@count).order('name ASC')

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.authors @authors, :id, :name
            data.page @page
          end
          json.success true
        end

        render json: json, status: 200
      end

      def show
        author = Author.find(params[:id])
        @quotes = author.quotes.page(@page).per(@count).order('body ASC')
        
        json = Jbuilder.encode do |json|
          json.data do |data|
            data.quotes @quotes, :id, :author_full_name, :body
            data.page @page
          end
          json.success true
        end

        render json: json, status: 200
      end

      private

        def set_page_and_count
          @page = params[:page].present? ? params[:page] || 1
          @count = params[:count].present? ? params[:count] || 10
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
