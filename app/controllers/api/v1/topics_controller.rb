module Api
  module V1
    class TopicsController < Api::BaseController

      before_filter :set_page_and_count
      before_filter :validate_topic_object, only: [:show]
      
      def index
        @topics = Topic.page(@page).per(@count).order('name ASC')

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.topics @topics, :id, :name
            data.page @page
          end
          json.success true
        end

        render json: json, status: 200
      end

      def show
        topic = Topic.find(params[:id])
        @quotes = topic.quotes.page(@page).per(@count).order('body ASC')
        
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
          @page = params[:page].present? ? params[:page] : 1
          @count = params[:count].present? ? params[:count] : 10
        end

        def ensure_params_id_exist
          return unless params[:id].blank?
          render json: { success: false, message: "Missing topic_id parameter" }, status: 200
        end

        def check_existence_of_topic
          return if Topic.exists?(id: params[:id])
          render json: { success: false, message: "Topic not found" }, status: 200
        end

        def validate_topic_object
          ensure_params_id_exist || check_existence_of_topic
        end

    end
  end
end
