class Admin::PresetCategoriesController < AdminController
  def index
    @categories = PresetCategory.includes(:preset_images).page(params[:page]).per(10)
  end

  def create
    preset_category = PresetCategory.new(params[:preset_category])
    
    if preset_category.save    
      redirect_to :back, notice: "Successfully created a category."
    else
      redirect_to :back, alert: "Category name can't be blank."
    end
  end

  def show
    @category = PresetCategory.find(params[:id])
    @images = @category.preset_images.page(params[:page]).per(10)
  end

  def destroy
    category = PresetCategory.find(params[:id])
    category.destroy

    redirect_to admin_preset_images_url, notice: "Successfully deleted a category. All associated images are marked as unassigned."
  end
end
