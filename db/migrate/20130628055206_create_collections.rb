class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.integer :user_id, null: false
      t.integer :post_id, null: false

      t.timestamps
    end

    add_index :collections, [:user_id, :post_id], unique: true
  end
end
