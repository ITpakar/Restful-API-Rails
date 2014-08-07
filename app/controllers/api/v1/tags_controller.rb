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

        page = params[:page] || 1
        count = params[:count] || 10

        @posts = tag.posts.page(page).per(count)

        json = Response::Collection.new('post', @posts, { instance_tag_id: tag.id, page: page, api_version: @api_version }).to_json

        render json: json, status: 200
      end

      protected

        def ensure_params_id_exist
          return unless params[:id].blank?
          render json: { success: false, message: "Missing tagname parameter" }, status: 200
        end

        def response_for_tag(tag)
          if tag.present?
            json = Response::Object.new('tag', tag, {api_version: @api_version}).to_json
            
            render json: json, status: 200
          else
            render json: { success: false, message: "Tagname not found" }, status: 200
          end
        end
    end
  end
end