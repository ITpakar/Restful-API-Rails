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
#

class Post < ActiveRecord::Base
  attr_accessible :caption, :editors_pick, :likes_count, :quote, :quote_image_name, :quote_image_uid

  belongs_to :user

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :likes, as: :likable, dependent: :destroy
  has_many :users_liked, through: :likes, source: :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :users_commented, through: :comments, source: :user

  validates_presence_of :quote#, :quote_image

  image_accessor :quote_image

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

  def to_builder
    bool_errors = self.errors.present?
    Jbuilder.new do |json|
      json.data do |data|
        data.post do |post|
          post.(self, :caption, :editors_pick, :likes_count, :quote)
          post.post_id self.id
          
          if self.quote_image.present?
            post.quote_image_url = self.quote_image.jpg.url
          else
            post.quote_image_url = ''
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
