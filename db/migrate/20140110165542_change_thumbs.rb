class ChangeThumbs < ActiveRecord::Migration
  def up
    drop_table :thumbs
    create_table "thumbs" do |t|
      t.string   "uid"
      t.string   "signature"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  end

  def down
    drop_table :thumbs
    create_table "thumbs" do |t|
      t.string   "uid"
      t.string   "job"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  end
end
