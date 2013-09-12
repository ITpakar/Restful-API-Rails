class AddPostedAtToPosts < ActiveRecord::Migration
  def up
    add_column :posts, :posted_at, :string

    Post.all.each do |post|
      post.update_attribute(:posted_at, post.created_at.to_i)
    end

    add_index :posts, :posted_at
  end

  def down
    remove_column :posts, :posted_at
  end
end
