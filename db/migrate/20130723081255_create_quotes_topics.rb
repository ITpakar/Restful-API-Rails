class CreateQuotesTopics < ActiveRecord::Migration
  def change
    create_table :quotes_topics do |t|
      t.integer :quote_id, null: false
      t.integer :topic_id, null: false
    end

    add_index :quotes_topics, [:quote_id, :topic_id], unique: true
  end
end
