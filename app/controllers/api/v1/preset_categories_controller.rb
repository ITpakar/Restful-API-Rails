module Api
  module V1
    class PresetCategoriesController < Api::BaseController
      
      skip_before_filter :validate_authentication_token
      before_filter :validate_preset_category_object, only: [:show]

      def index
        @categories = PresetCategory.all

        json = Jbuilder.encode do |json|
          json.data do |data|
            data.categories @categories, :id, :name, :preset_images_count, :preset_image_sample
          end
          json.success true
        end

        render json: json, status: 200
      end

      def show
        category = PresetCategory.find(params[:id])

        render json: category.to_builder.target!, status: 200
      end

      protected

        def ensure_params_id_exist
          return unless params[:id].blank?
          render json: { success: false, message: "Missing category id" }, status: 200
        end

        def check_existence_of_preset_category
          return if PresetCategory.exists?(id: params[:id])
          render json: { success: false, message: "Preset image not found" }, status: 200
        end

        def validate_preset_category_object
          ensure_params_id_exist || check_existence_of_preset_category
        end

    end
  end
end