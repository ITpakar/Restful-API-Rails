class Admin::PresetCategoriesController < AdminController
  def create
    preset_category = PresetCategory.new(params[:preset_category])
    
    if preset_category.save    
      redirect_to admin_preset_images_url, notice: "Successfully created a category."
    else
      redirect_to :back, alert: "Category name can't be blank."
    end
  end

  def destroy
    category = PresetCategory.find(params[:id])
    category.destroy

    redirect_to admin_preset_images_url, notice: "Successfully deleted a category. All associated images are marked as unassigned."
  end
end
