class AddFirstNameAndLastNameToAuthors < ActiveRecord::Migration
  def change
    add_column :authors, :first_name, :string
    add_column :authors, :last_name, :string
  end
end
