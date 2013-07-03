class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :collection_count, :integer, null: false, default: 0
    add_column :users, :birth_date, :date
    add_column :users, :gender, :string
  end
end
