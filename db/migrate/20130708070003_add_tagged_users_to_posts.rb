class AddTaggedUsersToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :tagged_users, :text
  end
end
