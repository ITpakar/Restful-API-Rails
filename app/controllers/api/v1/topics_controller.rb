module Api
  module V1
    class TopicsController < Api::BaseController

      before_filter :set_page_and_count
      before_filter :validate_topic_object, only: [:show]
      
      def index
        @topics = Topic.page(@page).per(@count).order('name ASC')

        json = Response::Collection.new('topic', @topics, { page: @page }).to_json

        render json: json, status: 200
      end

      def show
        topic = Topic.find(params[:id])
        @quotes = topic.quotes.page(@page).per(@count).order('author_full_name ASC, body ASC')
          
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
