class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :quote, default: '', null: false
      t.text :caption, default: '', null: false
      t.string :quote_image_uid
      t.string :quote_image_name
      t.boolean :editors_pick, default: false, null: false
      t.integer :likes_count, default: 0, null: false
      t.integer :user_id

      t.timestamps
    end

    add_index :posts, :user_id
    add_index :posts, :editors_pick
  end
end
