class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.text :body, default: '', null: false
      t.integer :author_id
      t.text :tags

      t.timestamps
    end

    add_index :quotes, :author_id
  end
end
