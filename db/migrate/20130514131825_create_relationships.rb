class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :follower_id, null: false
      t.integer :user_id, null: false
      t.string :status, null: false, default: 'approved'

      t.timestamps
    end

    add_index :relationships, :follower_id, unique: true
    add_index :relationships, :user_id, unique: true
    add_index :relationships, [:follower_id, :user_id], unique: true
  end
end
