module Api
  module V1
    class TagsController < Api::BaseController
      
      before_filter :validate_authentication_token
      before_filter :ensure_params_id_exist

      def show
        name = params[:id].downcase
        tag = Tag.find_by_name(params[:id])
        return response_for_tag(tag)
      end

      def search
        name = params[:id].downcase
        tags = Tag.where("name LIKE ?", name + '%').order("name ASC")

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.tags tags, :name, :posts_count
          end
          json.success true
        end

        render json: json, status: 200
      end

      def recent
        name = params[:id].downcase
        tag = Tag.find_by_name(name)
        return response_for_tag(tag) unless tag.present?

        hash_conditions = {}
        hash_conditions.update(min_id: params[:min_id]) if params[:min_id].present?
        hash_conditions.update(max_id: params[:max_id]) if params[:max_id].present?

        render json: tag.to_builder(true, hash_conditions).target!, status: 200
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