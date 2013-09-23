class AddAuthorFirstNameAndAuthorLastNameToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :author_first_name, :string
    add_column :quotes, :author_last_name, :string
  end
end
