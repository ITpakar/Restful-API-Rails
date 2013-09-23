class AddPostIdAndCommentIdToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :post_id, :integer
    add_column :activities, :comment_id, :integer

    add_index :activities, :post_id
    add_index :activities, :comment_id
  end
end
