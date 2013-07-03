module Api
  module V1
    class TagsController < Api::BaseController
      
      before_filter :ensure_params_id_exist

      def show
        name = params[:id].downcase
        tag = Tag.find_by_name(params[:id])
        return response_for_tag(tag)
      end

      def recent
        name = params[:id].downcase
        tag = Tag.find_by_name(name)
        return response_for_tag(tag) unless tag.present?

        hash_conditions = {min_id: params[:min_id], max_id: params[:max_id]}
        hash_conditions.reject!{ |k,v| v.blank? }

        render json: tag.to_builder(hash_conditions, {posts: true}).target!, status: 200
      end

      protected

        def ensure_params_id_exist
          return unless params[:id].blank?
          render json: { success: false, message: "Missing tagname parameter" }, status: 200
        end

        def response_for_tag(tag)
          if tag.present?
            render json: tag.to_builder.target!, status: 200
          else
            render json: { success: false, message: "Tagname not found" }, status: 200
          end
        end
    end
  end
end