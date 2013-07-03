class CreatePresetImages < ActiveRecord::Migration
  def change
    create_table :preset_images do |t|
      t.string :preset_image_uid
      t.string :preset_image_name
      t.integer :preset_category_id

      t.timestamps
    end

    add_index :preset_images, :preset_category_id
  end
end
