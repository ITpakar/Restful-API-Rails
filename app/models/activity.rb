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

  def tagged_details(options = {})
    hash = {}
    
    user_ids = self.tagged_users.keys
    users = User.where(id: user_ids)
    users.each do |user|
      hash.update(
        "@[user:#{user.id}]" => Response::Object.new('user', user, options).user_hash
      )
    end

    if self.custom_payloads.present? and self.custom_payloads.symbolize_keys[:post_id].present?
      post_id = self.custom_payloads.symbolize_keys[:post_id]
      post = Post.where(id: post_id).first
      hash.update(
        post: Response::Object.new('post', post, options).post_hash(post)
      ) if post.present?
    end

    return hash
  end

  def self.for_new_follower_to(user_id, actor_id)
    user, actor, options = set_arguments_for_variables(user_id, actor_id, {})

    message = user.am_follower?(actor.id) ? "followed you back" : "followed you"

    activity_with_user_and_actor(user, actor, {
      code: 100,
      description: 'new_follower',
      message: message
    })
  end

  def self.for_fb_friend_joins_to(user_id, actor_id)
    user, actor, options = set_arguments_for_variables(user_id, actor_id, {})

    activity_with_user_and_actor(user, actor, {
      code: 101,
      description: 'fb_friend_joins',
      message: "joined from Facebook"
    })
  end

  def self.for_likes_your_post_to(user_id, actor_id, options = {})
    activity_with_post(user_id, actor_id, options, {
      code: 102,
      description: 'likes_your_post',
      message: "liked your quote"
    })
  end

  def self.for_comments_on_your_post_to(user_id, actor_id, options = {})
    activity_with_comment(user_id, actor_id, options, {
      code: 103,
      description: 'comments_on_your_post',
      message: "commented on your quotiful"
    })
  end

  def self.for_comments_after_you_to(user_id, actor_id, options = {})
    activity_with_comment(user_id, actor_id, options, {
      code: 104,
      description: 'comments_after_you',
      message: "commented after you"
    })
  end

  def self.for_requotes_your_post_to(user_id, actor_id, options = {})
    activity_with_post(user_id, actor_id, options, {
      code: 105,
      description: 'requotes_your_post',
      message: "requoted your post"
    })
  end

  def self.for_tagged_in_post_to(user_id, actor_id, options = {})
    activity_with_post(user_id, actor_id, options, {
      code: 106,
      description: 'tagged_in_post',
      message: "tagged you in a post"
    })
  end

  def self.for_tagged_in_comment_to(user_id, actor_id, options = {})
    activity_with_comment(user_id, actor_id, options, {
      code: 107,
      description: 'tagged_in_comment',
      message: "tagged you in a comment"
    })
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

    push_notification(user, activity, 108, "Your quotiful has been featured!") if user.notifications.post_gets_featured
  end

  def self.for_saves_your_quotiful_to(user_id, actor_id, options = {})
    activity_with_post(user_id, actor_id, options, {
      code: 109,
      description: 'saves_your_quotiful',
      message: "saved your quotiful to their collection"
    })
  end

  private

    def self.set_arguments_for_variables(user_id, actor_id = nil, options = {})
      user = User.find(user_id)
      actor = User.find(actor_id) if actor_id.present?
      [user, actor, options.symbolize_keys!]
    end

    def self.activity_with_user_and_actor(user, actor, details) 
      activity = user.activities.for(details[:description]).create(
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
            code: details[:code],
            description: details[:description]
          }
        },
        body: "@[user:#{actor.id}] #{details[:message]}",
      )

      apn_via_settings(user, actor, activity, details)
    end

    def self.activity_with_post(user_id, actor_id, options, details)
      user, actor, options = set_arguments_for_variables(user_id, actor_id, options.dup)

      
      activity = user.activities.for(details[:description]).create(
        activity_attributes_with_post(actor, details, options)
      )

      apn_via_settings(user, actor, activity, details)
    end

    def self.activity_with_comment(user_id, actor_id, options, details)
      user, actor, options = set_arguments_for_variables(user_id, actor_id, options.dup)

      activity = user.activities.for(details[:description]).create(
        activity_attributes_with_post(actor, details, options).deep_merge({
          custom_payloads: {
            comment_id: options[:comment_id]
          }, comment_id: options[:comment_id]
        })
      )

      apn_via_settings(user, actor, activity, details)
    end

    def self.activity_attributes_with_post(actor, details, options)
      {
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
            code: details[:code],
            description: details[:description]
          },
          post_id: options[:post_id]
        },
        body: "@[user:#{actor.id}] #{details[:message]}",
        post_id: options[:post_id]
      }
    end

    def self.apn_via_settings(user, actor, activity, details)
      push_notification(user, activity, details[:code], "#{actor.full_name} #{details[:message]}") if user.notifications.send(details[:description])
    end

    def self.push_notification(user, activity, code, alert)
      user_tokens = user.devices.map(&:device_token)
      user_tokens.each do |token|
        PushNotification.new(token, alert, { 
          identifier: code, 
          badge: user.activities.unread.size,
          custom: activity.custom_payloads 
        }).push
      end
    end

end
