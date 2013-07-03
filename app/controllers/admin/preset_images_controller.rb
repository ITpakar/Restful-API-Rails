class Admin::PresetImagesController < AdminController
  def index
    @images = PresetImage.includes(:preset_category).page(params[:page]).per(10).order('preset_categories.name ASC, preset_images.name ASC, preset_images.created_at DESC')
  end

  def create
    preset_image = PresetImage.new(params[:preset_image])

    if preset_image.save
      redirect_to admin_preset_images_url, notice: "Successfully uploaded a new image."
    else
      redirect_to :back, alert: "No image uploaded."
    end
  end

  def edit
    @image = PresetImage.find(params[:id])
  end

  def update
    @image = PresetImage.find(params[:id])

    image_params = params[:preset_image].dup

    if image_params[:preset_image].blank?
      image_params.delete(:preset_image)
    end

    if @image.update_attributes(image_params)
      redirect_to admin_preset_images_url, notice: "Successfully updated image."
    else
      redirect_to :back, alert: "Failed to update image."
    end
  end

  def destroy
    image = PresetImage.find(params[:id])
    image.destroy
    
    redirect_to admin_preset_images_url, notice: "Successfully deleted an image."
  end

  def assign
    category = PresetCategory.find(params[:preset_image][:preset_category_id])
    image = PresetImage.find(params[:id])
    image.assign!(category.id)
    
    redirect_to :back, notice: "Successfully categorized an image."    
  end

  def unassign
    image = PresetImage.find(params[:id])
    image.unassign!

    redirect_to :back, notice: "Successfully unassign image to this category."
  end

  def unassigned
    @images = PresetImage.unassigned.page(params[:page]).per(10)
  end
end