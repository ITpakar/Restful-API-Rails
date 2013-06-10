# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  authentication_token   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  full_name              :string(255)
#  profile_picture_uid    :string(255)
#  profile_picture_name   :string(255)
#  auto_accept            :boolean          default(TRUE)
#  facebook_id            :integer
#  bio                    :text             default(""), not null
#  website                :string(255)      default(""), not null
#  follows_count          :integer          default(0)
#  followed_by_count      :integer          default(0)
#  posts_count            :integer          default(0)
#  favorite_quote         :text
#  author_name            :string(255)
#  active                 :boolean          default(TRUE), not null
#  deactivated_at         :datetime
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :token_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation,
                  :full_name, :auto_accept, :facebook_id, :bio,
                  :website, :follows_count, :followed_by_count, :posts_count,
                  :profile_picture, :favorite_quote, :author_name, :notifications,
                  :profile_picture_url

  before_save :ensure_authentication_token

  image_accessor :profile_picture

  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :likable, source_type: 'Post'
  has_many :comments, dependent: :destroy
  has_many :commented_posts, through: :comments, source: :commentable, source_type: 'Post'
  
  has_many :relationships
  # REFACTOR: naming problem, list of users that the current user follows
  has_many :follows, class_name: 'Relationship', conditions: { relationships: { status: 'approved' } }, foreign_key: :follower_id
  has_many :followed_by_self, through: :follows, source: :user
  # REFACTOR: naming problem, list of users that follows current user
  has_many :followers, class_name: 'Relationship', conditions: { relationships: {status: 'approved'} }
  has_many :followed_by_users, through: :followers, source: :follower
  # REFACTOR: naming problem, list of users that requested to follow current user
  has_many :requests, class_name: 'Relationship', conditions: { relationships: { status: 'requested' } }
  has_many :requested_by_users, through: :requests, source: :follower

  validates_presence_of :full_name

  searchable do
    text :full_name do
      full_name.try(:downcase)
    end

    integer :id

    integer :follows_id, multiple: true do
      follows.map { |relationship| relationship.user_id } rescue []
    end

    integer :followers_id, multiple: true do
      followers.map { |relationship| relationship.follower_id }
    end

    string :full_name do
      full_name.try(:downcase)
    end
  end

  has_settings do |setting|
    setting.key :notifications, defaults: {
      new_follower: true,
      fb_friend_joins: false,
      likes_your_post: true,
      comments_on_your_post: true,
      comments_after_you: false,
      requotes_your_post: false,
      tagged_in_post: true,
      post_gets_featured: false
    }
  end

  def notifications=(value)
    if value.is_a?(Hash) and value.present?
      self.settings(:notifications).update_attributes! value
    end
  end

  def notifications
    setting = self.settings(:notifications)

    hash = Hashie::Mash.new

    %w(new_follower fb_friend_joins likes_your_post
      comments_on_your_post comments_after_you
      requotes_your_post tagged_in_post
      post_gets_featured).each do |noty|
      eval %Q{ hash.#{noty} = setting.#{noty} }
    end

    return hash
  end

  def authenticated_feed(options = {min_id: nil, max_id: nil, count: 10})
    arr_condition = []
    arr_condition << "posts.id > %s" % options[:min_id] if options[:min_id].present?
    arr_condition << "posts.id < %s" % options[:max_id] if options[:max_id].present?
    str_condition = arr_condition.join(" AND ")
    Post.where(user_id: [self.follows.map(&:user_id), self.id].flatten)
        .where(str_condition)
        .limit(options[:count])
        .order('created_at DESC')
  end

  def active_for_authentication?
    !!active
  end

  def inactive_message
    "Sorry, this account has been deactivated."
  end

  def reactivate!
    self.update_attribute(:active, true)
  end

  def deactivate!
    self.update_attribute(:active, false)
  end

  def facebook_id=(value)
    write_attribute(:facebook_id, value)
    write_attribute(:profile_picture_url, "http://graph.facebook.com/#{value}/picture?width=150&height=150")
  end

  def profile_picture_url(size = '')
    if profile_picture.present?
      size.present? ? profile_picture.thumb(size).url : profile_picture.jpg.url
    else
      default = Dragonfly[:images].fetch_file(ActionController::Base.helpers.asset_path('default.png'))
      size.present? ? default.thumb(size).url : default.jpg.url
    end
  end

  def to_builder(options = {with_notifications: false, is_current_user: false})
    bool_errors = self.errors.present?
    Jbuilder.new do |json|
      json.data do |data|
        data.user do |user|
          user.(self, :full_name, :favorite_quote, :author_name, :website, :follows_count, :followed_by_count, :posts_count)
          user.user_id self.id

          if options[:with_notifications]
            user.notifications self.notifications
          end

          if options[:is_current_user]
            user.(self, :email, :authentication_token)
          end

          user.profile_picture self.profile_picture_url
        end
        
        if bool_errors
          data.errors self.errors.full_messages
        end
      end
      json.success !bool_errors
    end
  end
end
