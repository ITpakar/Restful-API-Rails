# == Schema Information
#
# Table name: taggings
#
#  id            :integer          not null, primary key
#  taggable_id   :integer
#  taggable_type :string(255)
#  user_id       :integer
#  tag_id        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Tagging < ActiveRecord::Base
  attr_accessible :taggable_id, :taggable_type, :user_id, :tag_id

  belongs_to :tag
  belongs_to :taggable, polymorphic: true
  belongs_to :user
end
