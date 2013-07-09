# == Schema Information
#
# Table name: posts
#
#  id                    :integer          not null, primary key
#  quote                 :text             default(""), not null
#  caption               :text             default(""), not null
#  quote_image_uid       :string(255)
#  quote_image_name      :string(255)
#  editors_pick          :boolean          default(FALSE), not null
#  likes_count           :integer          default(0), not null
#  user_id               :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  author_name           :string(255)      default("")
#  flagged               :boolean          default(FALSE), not null
#  flagged_count         :integer          default(0), not null
#  origin_id             :integer
#  background_image_uid  :string(255)
#  background_image_name :string(255)
#  quote_attr            :text
#  author_attr           :text
#  quotebox_attr         :text
#  tagged_users          :text
#

class Post < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  attr_accessible :author_name, :caption, :editors_pick,
                  :likes_count, :quote, :quote_image,
                  :background_image, :flagged, :flagged_count,
                  :origin_id, :quote_attr, :author_attr, :quotebox_attr,
                  :tagged_users

  belongs_to :user
  belongs_to :origin, class_name: 'Post'

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :likes, as: :likable, dependent: :destroy
  has_many :users_liked, through: :likes, source: :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :users_commented, through: :comments, source: :user

  validates_presence_of :quote

  image_accessor :quote_image
  image_accessor :background_image

  serialize :quote_attr, Hash
  serialize :author_attr, Hash
  serialize :quotebox_attr, Hash
  serialize :tagged_users, Hash

  scope :flagged, where(flagged: true)
  scope :editors_picked, where(editors_pick: true).order('posts.created_at DESC, posts.likes_count DESC')
  scope :popular, where("posts.likes_count > 0").order('posts.likes_count DESC, posts.created_at DESC')
  
  searchable do
    string :author_name

    integer :user_id

    text :caption
    text :quote
    text :author_name
    # text :tag_names do
    #   tag.map(&:name)
    # end
  end

  def origin_id=(value)
    write_attribute(:origin_id, value)
    origin = Post.find(value)

    Activity.for_requotes_your_post_to(poster.user_id, self.user_id)
  end

  def tagged_users=(raw)
    value = if raw.is_a?(String)
      ids = raw.split(',')
      users = User.where(id: ids)
      hash = {}
      users.each do |user|
        hash.update(user.id => {user_id: user.id, full_name: user.full_name})
        Activity.for_tagged_in_post_to(user.id, self.user_id)
      end
      hash
    else
      raw
    end

    write_attribute(:tagged_users, value)
  end

  def quote_image_url(size = '')
    if quote_image.present?
      size.present? ? quote_image.thumb(size).url : quote_image.jpg.url
    else
      path = File.join(Rails.root, 'public', 'default.png')
      default = Dragonfly[:images].fetch_file(path)
      size.present? ? default.thumb(size).url : default.jpg.url
    end
  end

  def liked_by?(user_id)
    self.likes.exists?(user_id: user_id)
  end

  def user_name
    if user.present?
      user.full_name
    else
      ''
    end
  end

  def pick!
    self.update_attribute(:editors_pick, true)
  end

  def unpick!
    self.update_attribute(:editors_pick, false)
  end

  def flag!
    self.update_attributes(flagged: true, flagged_count: self.flagged_count.next)
  end

  def to_builder
    bool_errors = self.errors.present?
    Jbuilder.new do |json|
      json.data do |data|
        data.post do |post|
          post.(self, :caption, :editors_pick, :likes_count, :quote)
          post.post_id self.id
          post.quote_image_url self.quote_image_url
          post.posted_at self.created_at.to_i
          post.web_url post_url(self, host: DEFAULT_HOST)
          post.background_image_url self.background_image_url
          post.quote_attr self.quote_attr
          post.author_attr self.author_attr
          post.quotebox_attr self.quotebox_attr
          post.origin_id self.origin_id
          post.tagged_users self.tagged_users
        end
        
        if bool_errors
          data.errors self.errors.full_messages
        end
      end
      json.success !bool_errors
    end
  end
end
