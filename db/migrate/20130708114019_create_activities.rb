class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.text :body
      t.text :tagged_users
      t.string :identifier
      t.boolean :viewed, default: false, null: false
      t.integer :user_id

      t.timestamps
    end

    add_index :activities, :user_id
  end
end
