# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  name        :string(255)      default(""), not null
#  posts_count :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Tag < ActiveRecord::Base
  attr_accessible :name, :posts_count

  has_many :taggings
  has_many :posts, through: :taggings, source: :taggable, source_type: 'Post'
  has_many :user, through: :taggings

  searchable do
    integer :id
    text :name do
      name.downcase
    end
    string :name do
      name.downcase
    end
  end

  validates_presence_of :name

end
