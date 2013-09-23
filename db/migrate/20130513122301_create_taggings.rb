class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.integer :taggable_id
      t.string :taggable_type
      t.integer :user_id
      t.integer :tag_id

      t.timestamps
    end

    add_index :taggings, [:taggable_id, :taggable_type]
    add_index :taggings, :tag_id
    add_index :taggings, :user_id
  end
end
