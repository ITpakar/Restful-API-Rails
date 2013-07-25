class AddSpamCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :spam_count, :integer, default: 0, null: false
  end
end
