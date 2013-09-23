class AddColumnsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :origin_id, :integer
    add_column :posts, :background_image_uid, :string
    add_column :posts, :background_image_name, :string
    add_column :posts, :quote_attr, :text
    add_column :posts, :author_attr, :text
    add_column :posts, :quotebox_attr, :text
  end
end
