# == Schema Information
#
# Table name: activities
#
#  id           :integer          not null, primary key
#  body         :text
#  tagged_users :text
#  identifier   :string(255)
#  viewed       :boolean          default(FALSE), not null
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Activity < ActiveRecord::Base
  
  attr_accessible :body, :identifier, :tagged_users, :viewed, :user_id

  belongs_to :user

  scope :for, lambda { |value| where(identifier: value) }
  scope :to, lambda { |value| where(user_id: value) }
  scope :unread, where(viewed: false)

  serialize :tagged_users

  # User#notifications
  # 100 - new_follower
  # 101 - fb_friend_joins
  # 102 - likes_your_post
  # 103 - comments_on_your_post
  # 104 - comments_after_you
  # 105 - requotes_your_post
  # 106 - tagged_in_post
  # 107 - post_gets_featured

  def self.for_new_follower_to(user_id, actor_id)
  	user = User.find(user_id)
  	actor = User.find(actor_id)

  	user.activities.for('new_follower').create(tagged_users: { actor.id => { full_name: actor.full_name, user_id: actor.id } })
  	if user.notifications.new_follower
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        if user.am_follower?(actor.id)
          PushNotification.new(token, "#{actor.full_name} followed you back", { identifier: 100, badge: user.activities.unread.size }).push
        else
          PushNotification.new(token, "#{actor.full_name} followed you", { identifier: 100, badge: user.activities.unread.size }).push
        end
      end
  	end
  end

  def self.for_fb_friend_joins_to(user_id, actor_id)
    user = User.find(user_id)
    actor = User.find(actor_id)

    user.activities.for('fb_friend_joins').create(tagged_users: { actor.id => { full_name: actor.full_name, user_id: actor.id } })
    if user.notifications.fb_friend_joins
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} joined from Facebook", { identifier: 101, badge: user.activities.unread.size }).push
      end
    end
  end

  def self.for_likes_your_post_to(user_id, actor_id)
    user = User.find(user_id)
    actor = User.find(actor_id)

    user.activities.for('likes_your_post').create(tagged_users: { actor.id => { full_name: actor.full_name, user_id: actor.id } })
    if user.notifications.likes_your_post
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} liked your quote", { identifier: 102, badge: user.activities.unread.size }).push
      end
    end
  end

  def self.for_comments_on_your_post_to(user_id, actor_id)
    user = User.find(user_id)
    actor = User.find(actor_id)

    user.activities.for('comments_on_your_post').create(tagged_users: { actor.id => { full_name: actor.full_name, user_id: actor.id } })
    if user.notifications.comments_on_your_post
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} commented on your quotiful", { identifier: 103, badge: user.activities.unread.size }).push
      end
    end
  end

  def self.for_comments_after_you_to(user_id, actor_id)
    user = User.find(user_id)
    actor = User.find(actor_id)

    user.activities.for('comments_after_you').create(tagged_users: { actor.id => { full_name: actor.full_name, user_id: actor.id } })
    if user.notifications.comments_after_you
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} commented after you", { identifier: 104, badge: user.activities.unread.size }).push
      end
    end
  end

  def self.for_requotes_your_post_to(user_id, actor_id)
    user = User.find(user_id)
    actor = User.find(actor_id)

    user.activities.for('requotes_your_post').create(tagged_users: { actor.id => { full_name: actor.full_name, user_id: actor.id } })
    if user.notifications.requotes_your_post
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} requoted your post", { identifier: 105, badge: user.activities.unread.size }).push
      end
    end
  end

  def self.for_tagged_in_post_to(user_id, actor_id)
    user = User.find(user_id)
    actor = User.find(actor_id)

    user.activities.for('tagged_in_post').create(tagged_users: { actor.id => { full_name: actor.full_name, user_id: actor.id } })
    if user.notifications.tagged_in_post
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} tagged you in a post", { identifier: 106, badge: user.activities.unread.size }).push
      end
    end
  end

  def self.for_tagged_in_comment_to(user_id, actor_id)
    user = User.find(user_id)
    actor = User.find(actor_id)

    user.activities.for('tagged_in_comment').create(tagged_users: { actor.id => { full_name: actor.full_name, user_id: actor.id } })
    if user.notifications.tagged_in_post
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} tagged you in a comment", { identifier: 106, badge: user.activities.unread.size }).push
      end
    end
  end

  def self.for_post_gets_featured_to(user_id)
    user = User.find(user_id)

    user.activities.for('post_gets_featured').create(tagged_users: { actor.id => { full_name: actor.full_name, user_id: actor.id } })
    if user.notifications.post_gets_featured
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "Your quotiful has been featured!", { identifier: 107, badge: user.activities.unread.size }).push
      end
    end
  end

end
