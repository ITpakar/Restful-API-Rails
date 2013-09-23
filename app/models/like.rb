# == Schema Information
#
# Table name: likes
#
#  id           :integer          not null, primary key
#  likable_id   :integer          not null
#  likable_type :string(255)      not null
#  user_id      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Like < ActiveRecord::Base
  attr_accessible :likable_id, :likable_type, :user_id

  belongs_to :likable, polymorphic: true
  belongs_to :user
end
