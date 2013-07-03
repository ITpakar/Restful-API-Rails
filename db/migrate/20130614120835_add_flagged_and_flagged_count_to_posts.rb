class AddFlaggedAndFlaggedCountToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :flagged, :boolean, default: false, null: false
    add_column :posts, :flagged_count, :integer, default: 0, null: false
  end
end
