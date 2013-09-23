class AddInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :full_name, :string
    add_column :users, :profile_picture_uid, :string
    add_column :users, :profile_picture_name, :string
    add_column :users, :auto_accept, :boolean, default: true
    add_column :users, :facebook_id, :integer
    add_column :users, :bio, :text
    add_column :users, :website, :string
    add_column :users, :follows_count, :integer, default: 0
    add_column :users, :followed_by_count, :integer, default: 0
    add_column :users, :posts_count, :integer, default: 0
  end
end
