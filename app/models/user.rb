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
#  facebook_id            :string(255)
#  website                :string(255)      default(""), not null
#  favorite_quote         :text
#  author_name            :string(255)
#  active                 :boolean          default(TRUE), not null
#  deactivated_at         :datetime
#  birth_date             :date
#  gender                 :string(255)
#  facebook_token         :string(255)
#  spam_count             :integer          default(0), not null
#  has_password           :boolean          default(TRUE), not null
#  suggested              :boolean          default(FALSE), not null
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :token_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation,
                  :full_name, :auto_accept, :facebook_id, :has_password,
                  :website, :follows_count, :followed_by_count, :posts_count,
                  :profile_picture, :favorite_quote, :author_name, :notifications,
                  :profile_picture_url, :birth_date, :gender, :facebook_token, :spam_count, :suggested

  before_save :ensure_authentication_token

  # image_accessor :profile_picture
  dragonfly_accessor :profile_picture do
    default 'public/default-avatar.png'
    after_assign do |i|
      [i.job, i.thumb('56x56#'), i.thumb('140x140#')].each do |job|
        thumb = Thumb.find_or_initialize_by_signature(job.signature)
        next unless thumb.new_record?
        thumb.uid = job.store
        thumb.save
      end
    end
  end

  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :likable, source_type: 'Post'
  has_many :comments, dependent: :destroy
  has_many :commented_posts, through: :comments, source: :commentable, source_type: 'Post'
  has_many :activities, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :collections, dependent: :destroy
  has_many :collected_posts, through: :collections, source: :post
  
  has_many :relationships, dependent: :destroy
  # REFACTOR: naming problem, list of users that the current user follows
  has_many :follows, class_name: 'Relationship', conditions: { relationships: { status: 'approved' } }, foreign_key: :follower_id
  has_many :followed_by_self, through: :follows, source: :user
  # REFACTOR: naming problem, list of users that follows current user
  has_many :followers, class_name: 'Relationship', conditions: { relationships: {status: 'approved'} }
  has_many :followed_by_users, through: :followers, source: :follower
  # REFACTOR: naming problem, list of users that requested to follow current user
  has_many :requests, class_name: 'Relationship', conditions: { relationships: { status: 'requested' } }
  has_many :requested_by_users, through: :requests, source: :follower
  has_many :blocks, class_name: 'Relationship', conditions: { relationships: { status: 'blocked' } }
  has_many :blockers, through: :blocks, source: :follower

  validates_presence_of :full_name
  # validates_uniqueness_of :facebook_id

  scope :spammers, where("users.spam_count > 0").order('users.active ASC, users.spam_count DESC')
  scope :suggested, where("users.suggested = ?", true)
  scope :active, where("users.active = ?", true)

  searchable do
    text :full_name do
      full_name.try(:downcase)
    end

    string :email

    integer :id

    boolean :active

    integer :follows_id, multiple: true do
      follows.map { |relationship| relationship.user_id } rescue []
    end

    integer :followers_id, multiple: true do
      followers.map { |relationship| relationship.follower_id }
    end

    integer :blockers_id, multiple: true do
      blocks.map { |relationship| relationship.follower_id }
    end

    string :full_name do
      full_name.try(:downcase)
    end
  end

  has_settings do |setting|
    setting.key :notifications, defaults: {
      new_follower: true,
      fb_friend_joins: true,
      likes_your_post: true,
      comments_on_your_post: true,
      comments_after_you: true,
      requotes_your_post: true,
      tagged_in_post: true,
      post_gets_featured: true,
      saves_your_quotiful: true
    }
  end

  def using_this_device(device_token)
    if device_token.present?
      device = Device.find_or_initialize_by_device_token(device_token)
      device.user = self
      device.save
    end
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
      post_gets_featured saves_your_quotiful).each do |noty|
      eval %Q{ hash.#{noty} = ['1', 1, true].member?(setting.#{noty}) }
    end

    hash.tagged_in_comment = hash.tagged_in_post

    return hash
  end

  def authenticated_feed(options = {page: 1, count: 10})
    Post.where(user_id: [self.follows.map(&:user_id), self.id].flatten)
        .order('created_at DESC')
        .page(options[:page]).per(options[:count])
  end

  def active_for_authentication?
    !!active
  end

  def set_reset_password_token!
    self.reset_password_token = User.reset_password_token
    self.reset_password_sent_at = Time.now.utc
    self.save(validate: false)
  end

  def inactive_message
    "Sorry, this account has been deactivated."
  end

  def is_spammer!
    self.update_attribute(:spam_count, self.spam_count.next)
  end

  def reactivate!
    self.update_attribute(:active, true)
  end

  def deactivate!
    self.update_attribute(:active, false)
    Users::Mailer.deactivation(self.id).deliver
  end

  def facebook_id=(value)
    write_attribute(:facebook_id, value)
    self.capture_facebook_avatar    
  end

  def capture_facebook_avatar(update_now = false)
    if !self.profile_picture.present? and self.facebook_id.present?
      response = Net::HTTP.get_response("graph.facebook.com", "/#{self.facebook_id}/picture?width=150&height=150").to_hash rescue {}
      self.profile_picture_url = response['location'].to_a.first
      self.save if update_now
    end
  end

  def profile_picture_url(size = '')
    Common.image_url(profile_picture, size)
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |user|
        csv << user.attributes.values_at(*column_names)
      end
    end
  end

  def following_me?(user_id)
    relationship = followers.find_thru_followers(user_id).first
    relationship.present? && relationship.status.eql?('approved')
  end

  def am_follower?(user_id)
    relationship = follows.find_thru_follows(user_id).first
    relationship.present? && relationship.status.eql?('approved')
  end

  def following_date(user_id)
    relationship = self.followers.find_thru_followers(user_id).first
    relationship.try(:created_at).to_i
  end

  def follower_date(user_id)
    relationship = self.follows.find_thru_follows(user_id).first
    relationship.try(:created_at).to_i
  end
  
end
