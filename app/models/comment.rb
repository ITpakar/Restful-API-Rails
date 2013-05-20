# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_id   :integer
#  commentable_type :string(255)
#  user_id          :integer
#  body             :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Comment < ActiveRecord::Base
  attr_accessible :body, :commentable_id, :commentable_type, :user_id

  belongs_to :commentable, polymorphic: true
  belongs_to :user
end
