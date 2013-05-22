class ChangeIndexForRelationships < ActiveRecord::Migration
  def up
    remove_index :relationships, :follower_id
    remove_index :relationships, :user_id
    add_index :relationships, :follower_id
    add_index :relationships, :user_id
  end

  def down
    remove_index :relationships, :follower_id
    remove_index :relationships, :user_id
    add_index :relationships, :follower_id
    add_index :relationships, :user_id
  end
end
