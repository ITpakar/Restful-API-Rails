# == Schema Information
#
# Table name: relationships
#
#  id          :integer          not null, primary key
#  follower_id :integer          not null
#  user_id     :integer          not null
#  status      :string(255)      default("approved"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Relationship < ActiveRecord::Base
  attr_accessible :status, :follower_id, :user_id

  belongs_to :follower, class_name: 'User'
  belongs_to :user

  scope :approved, where(status: 'approved')
  scope :blocked, where(status: 'blocked')
  scope :find_thru_follows, lambda { |user_id| where(user_id: user_id) }
  scope :find_thru_followers, lambda { |user_id| where(follower_id: user_id) }

  def approve!
    update_attribute(:status, 'approved')

    user_tokens = user.devices.map(&:device_token)
    user_tokens.each do |token|
      if user.am_follower?(follower.id)
        PushNotification.new(token, "#{follower.full_name} followed you back").push
      else
        PushNotification.new(token, "#{follower.full_name} followed you").push
      end
    end

    self.user.increment!(:followed_by_count)
    self.follower.increment!(:follows_count)

    # SOLR: save changes to solr index
    self.user.index
    self.follower.index
    Sunspot.commit
  end

  def block!
    update_attribute(:status, 'blocked')
  end

  def request!
    update_attribute(:status, 'requested')
  end

  def follow!
    self.user.auto_accept? ? self.approve! : self.request!
  end

  def to_builder
    bool_errors = self.errors.present?
    Jbuilder.new do |json|
      json.data do |data|
        data.relationship do |relationship|
          relationship.(self, :status, :follower_id)
        end
        
        if bool_errors
          data.errors self.errors.full_messages
        end
      end
      json.success !bool_errors
    end
  end

  alias :deny! :destroy
  alias :unfollow! :destroy
  alias :unblock! :destroy
end
