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
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :token_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation,
                  :full_name, :auto_accept, :facebook_id, :bio,
                  :website, :follows_count, :followed_by_count, :posts_count

  before_save :ensure_authentication_token

  image_accessor :profile_picture

  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :likable, source_type: 'Post'
  has_many :relationships
  # REFACTOR: naming problem, list of users that the current user follows
  has_many :follows, class_name: 'Relationship', conditions: { relationships: { status: 'approved' } }
  has_many :followed_by_self, through: :follows, source: :user
  # REFACTOR: naming problem, list of users that follows current user
  has_many :followers, class_name: 'Relationship', conditions: { relationships: {status: 'approved'} }
  has_many :followed_by_users, through: :followers, source: :follower
  # REFACTOR: naming problem, list of users that requested to follow current user
  has_many :requests, class_name: 'Relationship', conditions: { relationships: { status: 'requested' } }
  has_many :requested_by_users, through: :requests, source: :follower

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

  def published_feed(options = {min_id: nil, max_id: nil, min_timestamp: nil, max_timestamp: nil, count: 10})
    
  end

  def to_builder
    bool_errors = self.errors.present?
    Jbuilder.new do |json|
      json.data do |data|
        data.user do |user|
          user.(self, :full_name, :bio, :website, :follows_count, :followed_by_count, :posts_count, :email, :authentication_token)
          user.user_id self.id

          if self.profile_picture.present?
            user.profile_picture = self.profile_picture.jpg.url
          elsif self.facebook_id.present?
            user.profile_picture = "http://graph.facebook.com/#{self.facebook_id}/picture?type=large"
          else
            user.profile_picture = ''
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
