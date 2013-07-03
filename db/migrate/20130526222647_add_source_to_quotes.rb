class AddSourceToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :source, :text
  end
end
