class AddFavoriteQuoteAndAuthorNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :favorite_quote, :text
    add_column :users, :author_name, :string
  end
end
