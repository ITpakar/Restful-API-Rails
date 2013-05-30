module Api
  module V1
    class PresetImagesController < Api::BaseController
      
      skip_before_filter :validate_authentication_token
      before_filter :validate_preset_image_object

      def show
        image = PresetImage.find(params[:id])

        render json: image.to_builder.target!, status: 200
      end

      protected

        def ensure_params_id_exist
          return unless params[:id].blank?
          render json: { success: false, message: "Missing image id" }, status: 200
        end

        def check_existence_of_preset_image
          return if PresetImage.exists?(id: params[:id])
          render json: { success: false, message: "Preset image not found" }, status: 200
        end

        def validate_preset_image_object
          ensure_params_id_exist || check_existence_of_preset_image
        end

    end
  end
end
