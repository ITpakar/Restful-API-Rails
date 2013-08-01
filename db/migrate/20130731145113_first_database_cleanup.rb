class FirstDatabaseCleanup < ActiveRecord::Migration
  def up
    remove_column :users, :bio
    remove_column :users, :posts_count
    remove_column :users, :collection_count
    remove_column :users, :follows_count
    remove_column :users, :followed_by_count
  end

  def down
    add_column :users, :bio, :text
    add_column :users, :posts_count, :integer, default: 0, null: false
    add_column :users, :collection_count, :integer, default: 0, null: false
    add_column :users, :follows_count, :integer, default: 0, null: false
    add_column :users, :followed_by_count, :integer, default: 0, null: false

    User.all.each do |user|
      user.posts_count = user.posts.count
      user.collection_count = user.collections.count
      user.followed_by_count = user.followers.count
      user.follows_count = user.follows.count
      user.save
    end
  end
end
