class AddHasPasswordFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_password, :boolean, default: true, null: false
  end
end
