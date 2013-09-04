# encoding: utf-8

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
#  tagged_users     :text
#

class Comment < ActiveRecord::Base
  attr_accessible :body, :commentable_id, :commentable_type, :user_id, :tagged_users

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  has_many :activities, dependent: :destroy

  serialize :tagged_users

  validates_presence_of :body

  def tagged_users=(raw)
    value = if raw.is_a?(String)
      ids = raw.split(',')
      users = User.where(id: ids)
      hash = {}
      users.each do |user|
        hash.update(user.id => {user_id: user.id, full_name: user.full_name})
      end
      hash
    else
      raw
    end

    write_attribute(:tagged_users, value)
  end

  def tagged_users
    if super.present?
      super
    else
      {}
    end
  end

  def body=(value)
    encoded_str = Emoji.to_string(value)
    write_attribute(:body, encoded_str)
  end

  def description
    str = self.body.dup
    if self.tagged_users.present? and self.tagged_users.is_a?(Hash)
      self.tagged_users.keys.each do |user_id|
        full_name = User.where(id: user_id).first.try(:full_name)
        str = str.gsub("@[user:#{user_id}]", "@#{full_name}")
        str = Emoji.to_unicode(str)
      end
    end
    return str
  end
end
