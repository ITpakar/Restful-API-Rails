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

  validates_presence_of :body

  def to_builder
    bool_errors = self.errors.present?
    Jbuilder.new do |json|
      json.data do |data|
        data.comment do |comment|
          comment.body self.body
          comment.post_id self.commentable_id
          comment.commented_at self.created_at.to_i
          comment.set! :user do
            comment.set! :user_id, self.user_id
            comment.set! :full_name, self.user.full_name
            comment.set! :full_name, self.user.profile_picture_url
          end
        end
        
        if bool_errors
          data.errors self.errors.full_messages
        end
      end
      json.success !bool_errors
    end
  end
end