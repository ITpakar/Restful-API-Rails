# == Schema Information
#
# Table name: activities
#
#  id              :integer          not null, primary key
#  body            :text
#  tagged_users    :text
#  identifier      :string(255)
#  viewed          :boolean          default(FALSE), not null
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  custom_payloads :text
#  post_id         :integer
#  comment_id      :integer
#

class Activity < ActiveRecord::Base
  
  attr_accessible :body, :identifier, :tagged_users, :viewed, :user_id, :custom_payloads, :post_id, :comment_id

  belongs_to :user
  belongs_to :post
  belongs_to :comment

  scope :for, lambda { |value| where(identifier: value) }
  scope :to, lambda { |value| where(user_id: value) }
  scope :unread, where(viewed: false)

  serialize :tagged_users
  serialize :custom_payloads

  # User#notifications
  # 100 - new_follower
  # 101 - fb_friend_joins
  # 102 - likes_your_post
  # 103 - comments_on_your_post
  # 104 - comments_after_you
  # 105 - requotes_your_post
  # 106 - tagged_in_post
  # 107 - tagged_in_comment
  # 108 - post_gets_featured
  # 109 - saves_your_quotiful

  def tagged_details
    hash = {}
    
    user_ids = self.tagged_users.keys
    users = User.where(id: user_ids)
    users.each do |user|
      hash.update(
        "@[user:#{user.id}]" => Response::Object.new('user', user).user_hash
      )
    end

    if self.custom_payloads.present? and self.custom_payloads.symbolize_keys[:post_id].present?
      post_id = self.custom_payloads.symbolize_keys[:post_id]
      post = Post.where(id: post_id).first
      hash.update(
        post: Response::Object.new('post', post).post_hash
      )
    end

    return hash
  end

  def self.for_new_follower_to(user_id, actor_id)
  	user = User.find(user_id)
  	actor = User.find(actor_id)

  	message = user.am_follower?(actor.id) ? "followed you back" : "followed you"

    activity = user.activities.for('new_follower').create(
      tagged_users: {
        actor.id => {
         full_name: actor.full_name, 
         user_id: actor.id 
        } 
      },
      custom_payloads: {
        "user:#{actor.id}" => {
          full_name: actor.full_name, 
          user_id: actor.id 
        },
        identifier: {
          code: 100,
          description: 'new_follower'
        }
      },
      body: "@[user:#{actor.id}] #{message}"
    )

  	if user.notifications.new_follower
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} #{message}", { 
          identifier: 100, 
          badge: user.activities.unread.size,
          custom: activity.custom_payloads
        }).push
      end
  	end
  end

  def self.for_fb_friend_joins_to(user_id, actor_id)
    user, actor, options = set_arguments_for_variables(user_id, actor_id, {})

    activity = user.activities.for('fb_friend_joins').create(
      tagged_users: {
        actor.id => { 
          full_name: actor.full_name, 
          user_id: actor.id 
        } 
      }, 
      custom_payloads: {
        "user:#{actor.id}" => {
          full_name: actor.full_name, 
          user_id: actor.id 
        },
        identifier: {
          code: 101,
          description: 'fb_friend_joins'
        }
      },
      body: "@[user:#{actor.id}] joined from Facebook"
    )

    if user.notifications.fb_friend_joins
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} joined from Facebook", { 
          identifier: 101, 
          badge: user.activities.unread.size,
          custom: activity.custom_payloads 
        }).push
      end
    end
  end

  def self.for_likes_your_post_to(user_id, actor_id, options = {})
    user, actor, options = set_arguments_for_variables(user_id, actor_id, options.dup)

    activity = user.activities.for('likes_your_post').create(
      tagged_users: { 
        actor.id => { 
          full_name: actor.full_name, 
          user_id: actor.id 
        } 
      }, 
      custom_payloads: {
        "user:#{actor.id}" => {
          full_name: actor.full_name, 
          user_id: actor.id 
        },
        identifier: {
          code: 102,
          description: 'likes_your_post'
        },
        post_id: options[:post_id]
      },
      body: "@[user:#{actor.id}] liked your quote",
      post_id: options[:post_id]
    )

    if user.notifications.likes_your_post
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} liked your quote", { 
          identifier: 102, 
          badge: user.activities.unread.size,
          custom: activity.custom_payloads 
        }).push
      end
    end
  end

  def self.for_comments_on_your_post_to(user_id, actor_id, options = {})
    user, actor, options = set_arguments_for_variables(user_id, actor_id, options.dup)

    activity = user.activities.for('comments_on_your_post').create(
      tagged_users: { 
        actor.id => { 
          full_name: actor.full_name, 
          user_id: actor.id 
        } 
      }, 
      custom_payloads: {
        "user:#{actor.id}" => {
          full_name: actor.full_name, 
          user_id: actor.id 
        },
        identifier: {
          code: 103,
          description: 'comments_on_your_post'
        },
        comment_id: options[:comment_id],
        post_id: options[:post_id]
      },
      body: "@[user:#{actor.id}] commented on your quotiful",
      comment_id: options[:comment_id],
      post_id: options[:post_id]
    )

    if user.notifications.comments_on_your_post
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} commented on your quotiful", { 
          identifier: 103, 
          badge: user.activities.unread.size,
          custom: activity.custom_payloads 
        }).push
      end
    end
  end

  def self.for_comments_after_you_to(user_id, actor_id, options = {})
    user, actor, options = set_arguments_for_variables(user_id, actor_id, options.dup)

    activity = user.activities.for('comments_after_you').create(
      tagged_users: { 
        actor.id => { 
          full_name: actor.full_name, 
          user_id: actor.id 
        } 
      },
      custom_payloads: {
        "user:#{actor.id}" => {
          full_name: actor.full_name, 
          user_id: actor.id 
        },
        identifier: {
          code: 104,
          description: 'comments_after_you'
        },
        comment_id: options[:comment_id],
        post_id: options[:post_id]
      }, 
      body: "@[user:#{actor.id}] commented after you",
      comment_id: options[:comment_id],
      post_id: options[:post_id]
    )

    if user.notifications.comments_after_you
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} commented after you", { 
          identifier: 104, 
          badge: user.activities.unread.size,
          custom: activity.custom_payloads 
        }).push
      end
    end
  end

  def self.for_requotes_your_post_to(user_id, actor_id, options = {})
    user, actor, options = set_arguments_for_variables(user_id, actor_id, options.dup)

    activity = user.activities.for('requotes_your_post').create(
      tagged_users: { 
        actor.id => { 
          full_name: actor.full_name, 
          user_id: actor.id 
        } 
      }, 
      custom_payloads: {
        "user:#{actor.id}" => {
          full_name: actor.full_name, 
          user_id: actor.id 
        },
        identifier: {
          code: 105,
          description: 'requotes_your_post'
        },
        post_id: options[:post_id]
      },
      body: "@[user:#{actor.id}] requoted your post",
      post_id: options[:post_id]
    )

    if user.notifications.requotes_your_post
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} requoted your post", { 
          identifier: 105, 
          badge: user.activities.unread.size,
          custom: activity.custom_payloads 
        }).push
      end
    end
  end

  def self.for_tagged_in_post_to(user_id, actor_id, options = {})
    user, actor, options = set_arguments_for_variables(user_id, actor_id, options.dup)

    activity = user.activities.for('tagged_in_post').create(
      tagged_users: { 
        actor.id => { 
          full_name: actor.full_name, 
          user_id: actor.id 
        } 
      }, 
      custom_payloads: {
        "user:#{actor.id}" => {
          full_name: actor.full_name, 
          user_id: actor.id 
        },
        identifier: {
          code: 106,
          description: 'tagged_in_post'
        },
        post_id: options[:post_id]
      },
      body: "@[user:#{actor.id}] tagged you in a post",
      post_id: options[:post_id]
    )

    if user.notifications.tagged_in_post
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} tagged you in a post", { 
          identifier: 106, 
          badge: user.activities.unread.size,
          custom: activity.custom_payloads 
        }).push
      end
    end
  end

  def self.for_tagged_in_comment_to(user_id, actor_id, options = {})
    user, actor, options = set_arguments_for_variables(user_id, actor_id, options.dup)

    activity = user.activities.for('tagged_in_comment').create(
      tagged_users: { 
        actor.id => { 
          full_name: actor.full_name, 
          user_id: actor.id 
        } 
      }, 
      custom_payloads: {
        "user:#{actor.id}" => {
          full_name: actor.full_name, 
          user_id: actor.id 
        },
        identifier: {
          code: 107,
          description: 'tagged_in_comment'
        },
        comment_id: options[:comment_id],
        post_id: options[:post_id]
      },
      body: "@[user:#{actor.id}] tagged you in a comment",
      comment_id: options[:comment_id],
      post_id: options[:post_id]
    )

    if user.notifications.tagged_in_post
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} tagged you in a comment", { 
          identifier: 107, 
          badge: user.activities.unread.size,
          custom: activity.custom_payloads 
        }).push
      end
    end
  end

  def self.for_post_gets_featured_to(user_id, options = {})
    user, actor, options = set_arguments_for_variables(user_id, nil, options.dup)

    activity = user.activities.for('post_gets_featured').create(
      tagged_users: {}, 
      custom_payloads: {
        post_id: options[:post_id],
        identifier: {
          code: 108,
          description: 'post_gets_featured'
        }
      },
      body: "Your quotiful has been featured!",
      post_id: options[:post_id]
    )

    if user.notifications.post_gets_featured
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "Your quotiful has been featured!", { 
          identifier: 108, 
          badge: user.activities.unread.size,
          custom: activity.custom_payloads 
        }).push
      end
    end
  end

  def self.for_saves_your_quotiful_to(user_id, actor_id, options = {})
    user, actor, options = set_arguments_for_variables(user_id, actor_id, options.dup)

    activity = user.activities.for('saves_your_quotiful').create(
      tagged_users: { 
        actor.id => { 
          full_name: actor.full_name, 
          user_id: actor.id 
        } 
      }, 
      custom_payloads: {
        "user:#{actor.id}" => {
          full_name: actor.full_name, 
          user_id: actor.id 
        },
        identifier: {
          code: 109,
          description: 'saves_your_quotiful'
        },
        post_id: options[:post_id]
      },
      body: "@[user:#{actor.id}] saved your quotiful to their collection",
      post_id: options[:post_id]
    )

    if user.notifications.saves_your_quotiful
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, "#{actor.full_name} saved your quotiful to their collection", { 
          identifier: 109, 
          badge: user.activities.unread.size,
          custom: activity.custom_payloads 
        }).push
      end
    end
  end

  private

    def set_arguments_for_variables(user_id, actor_id = nil, options = {})
      user = User.find(user_id)
      actor = User.find(actor_id) if actor_id.present?
      [user, actor, options.symbolize_keys!]
    end

end
