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

  has_many :activities, dependent: :destroy
  has_many :collections, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :likes, as: :likable, dependent: :destroy
  has_many :users_liked, through: :likes, source: :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :users_commented, through: :comments, source: :user

  # validates_presence_of :quote

  # image_accessor :quote_image
  # image_accessor :background_image
  dragonfly_accessor :quote_image do
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
  dragonfly_accessor :background_image do
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

  serialize :quote_attr, Hash
  serialize :author_attr, Hash
  serialize :quotebox_attr, Hash
  serialize :tagged_users

  scope :flagged, where(flagged: true)
  scope :editors_picked, where(editors_pick: true).order('posts.created_at DESC, posts.likes_count DESC')
  scope :popular, where("posts.likes_count > 0").order('posts.likes_count DESC, posts.created_at DESC')
  
  searchable do
    string :author_name
    string :user_name

    integer :user_id
    integer :likes_count
    integer :flagged_count

    text :caption
    text :quote
    text :author_name

    text :user_name

    boolean :editors_pick
    
    time :created_at
    # text :tag_names do
    #   tag.map(&:name)
    # end
  end

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

  def description
    str = self.caption.dup 
    if self.tagged_users.present? and self.tagged_users.is_a?(Hash)
      self.tagged_users.keys.each do |user_id|
        full_name = User.where(id: user_id).first.try(:full_name)
        str = str.gsub("@[user:#{user_id}]", "@#{full_name}")
      end
    end
    return str
  end

  def tagged_users
    if super.present?
      super
    else
      {}
    end
  end

  def caption=(raw)
    # value = raw.gsub(/(\u00e2\u0080\u0099|\u0027)/, "'").gsub(/[\u201c\u201d]/, '"')
    value = raw
    write_attribute(:caption, value)
  end

  def quote=(raw)
    # value = raw.gsub(/(\u00e2\u0080\u0099|\u0027)/, "'").gsub(/[\u201c\u201d]/, '"')
    value = raw
    write_attribute(:quote, value)
  end

  def quote_image_url(size = '')
    Common.image_url(quote_image, size)
  end

  def background_image_url(size = '')
    Common.image_url(background_image, size)
  end

  def liked_by?(user_id)
    self.likes.exists?(user_id: user_id)
  end

  def in_collection_of?(user_id)
    self.collections.exists?(user_id: user_id)
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
    Resque.enqueue(Jobs::Notify, :post_gets_featured, self.user_id, nil, {post_id: self.id})
  end

  def unpick!
    self.update_attribute(:editors_pick, false)
  end

  def flag!
    self.update_attributes(flagged: true, flagged_count: self.flagged_count.next)
  end
end
