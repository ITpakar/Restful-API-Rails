module Api
  module V1
    class TagsController < Api::BaseController
      
      before_filter :validate_authentication_token

      def show
        tag = Tag.find_by_name(params[:id])
        return response_for_tag(tag)
      end

      # REFACTOR: tag name "search" becomes reserve word for routes
      def search
        tag = Tag.find_by_name(params[:id])
        return response_for_tag(tag) unless tag.present?

        render json: tag.to_builder(true).target!, status: 200
      end

      def recent
        tag = Tag.find_by_name(params[:id])
        return response_for_tag(tag) unless tag.present?

        hash_conditions = {}
        hash_conditions.update(min_id: params[:min_id]) if params[:min_id].present?
        hash_conditions.update(max_id: params[:max_id]) if params[:max_id].present?
        
        render json: tag.to_builder(true, hash_conditions).target!, status: 200
      end

      protected

        def response_for_tag(tag)
          if tag.present?
            render json: tag.to_builder.target!, status: 200
          else
            render json: { success: false, message: "Tag not found" }, status: 200
          end
        end
    end
  end
end