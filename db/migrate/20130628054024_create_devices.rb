class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer :user_id
      t.string :device_token, null: false

      t.timestamps
    end

    add_index :devices, :user_id
    add_index :devices, :device_token
  end
end
