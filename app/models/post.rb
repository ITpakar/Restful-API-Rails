# == Schema Information
#
# Table name: posts
#
#  id               :integer          not null, primary key
#  quote            :text             default(""), not null
#  caption          :text             default(""), not null
#  quote_image_uid  :string(255)
#  quote_image_name :string(255)
#  editors_pick     :boolean          default(FALSE), not null
#  likes_count      :integer          default(0), not null
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  author_name      :string(255)      default("")
#

class Post < ActiveRecord::Base
  attr_accessible :author_name, :caption, :editors_pick, :likes_count, :quote, :quote_image

  belongs_to :user

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :likes, as: :likable, dependent: :destroy
  has_many :users_liked, through: :likes, source: :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :users_commented, through: :comments, source: :user

  validates_presence_of :quote

  image_accessor :quote_image

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

  def self.editors_picked(options = {})
    options.reverse_update(
      start_date: 7.days.ago,
      end_date: Time.now,
      min_id: nil,
      max_id: nil,
      count: 10
    )

    collection = self.where(editors_pick: true).order('posts.created_at DESC, posts.likes_count DESC').limit(options[:count])
    collection = collection.where("posts.created_at BETWEEN ? AND ?", options[:start_date], options[:end_date])
    collection = collection.where("posts.id > ?", options[:min_id]) if options[:min_id].present?
    collection = collection.where("posts.id < ?", options[:max_id]) if options[:max_id].present?

    return collection
  end

  def self.popular(options = {})
    options.reverse_update(
      start_date: 7.days.ago,
      end_date: Time.now,
      min_id: nil,
      max_id: nil,
      count: 10
    )

    collection = self.order('posts.likes_count DESC, posts.created_at DESC').limit(options[:count])
    collection = collection.where("posts.created_at BETWEEN ? AND ?", options[:start_date], options[:end_date])
    collection = collection.where("posts.id > ?", options[:min_id]) if options[:min_id].present?
    collection = collection.where("posts.id < ?", options[:max_id]) if options[:max_id].present?

    return collection
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

  def to_builder
    bool_errors = self.errors.present?
    Jbuilder.new do |json|
      json.data do |data|
        data.post do |post|
          post.(self, :caption, :editors_pick, :likes_count, :quote)
          post.post_id self.id
          post.quote_image_url self.quote_image_url
          post.posted_at self.created_at.to_i
        end
        
        if bool_errors
          data.errors self.errors.full_messages
        end
      end
      json.success !bool_errors
    end
  end
end
