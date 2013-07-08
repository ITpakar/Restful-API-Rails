class AddTaggedUsersToComments < ActiveRecord::Migration
  def change
    add_column :comments, :tagged_users, :text
  end
end
