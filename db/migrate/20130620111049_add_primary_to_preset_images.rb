class AddPrimaryToPresetImages < ActiveRecord::Migration
  def change
    add_column :preset_images, :primary, :boolean, null: false, default: false
  end
end
