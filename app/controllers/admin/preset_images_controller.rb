class Admin::PresetImagesController < AdminController
  def index
    @categories = PresetCategory.page(params[:page]).per(5)
    @images = PresetImage.page(params[:page]).per(5).order('created_at DESC')
  end

  def create
    preset_image = PresetImage.new(params[:preset_image])

    if preset_image.save
      redirect_to admin_preset_images_url, notice: "Successfully uploaded a new image."
    else
      redirect_to :back, alert: "No image uploaded."
    end
  end

  def destroy
    image = PresetImage.find(params[:id])
    image.destroy
    
    redirect_to admin_preset_images_url, notice: "Successfully deleted an image."
  end
end