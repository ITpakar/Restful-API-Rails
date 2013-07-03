class ChangeColumnForUsers < ActiveRecord::Migration
  def up
    change_column :users, :bio, :text, default: '', null: false
    change_column :users, :website, :string, default: '', null: false
  end

  def down
    change_column :users, :bio, :text
    change_column :users, :website, :string
  end
end
