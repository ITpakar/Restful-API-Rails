class AddNameToPresetImages < ActiveRecord::Migration
  def change
    add_column :preset_images, :name, :string, default: ''
  end
end
