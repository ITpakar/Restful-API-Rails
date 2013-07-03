class CreatePresetCategories < ActiveRecord::Migration
  def change
    create_table :preset_categories do |t|
      t.integer :preset_images_count, default: 0, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
