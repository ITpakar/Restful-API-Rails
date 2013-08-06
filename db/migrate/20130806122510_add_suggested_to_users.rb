class AddSuggestedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :suggested, :boolean, default: false, null: false
  end
end
