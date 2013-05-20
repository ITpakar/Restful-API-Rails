# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  name        :string(255)      default(""), not null
#  posts_count :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Tag < ActiveRecord::Base
  attr_accessible :name, :posts_count

  has_many :taggings
  has_many :posts, through: :taggings, source: :taggable, source_type: 'Post' do
    def from_min_id(min_id)
      if min_id.present?
        where("posts.id > ?", min_id)
      else
        return self
      end
    end

    def to_max_id(max_id)
      if max_id.present?
        where("posts.id < ?", min_id)
      else
        return self
      end
    end

    def find_with_conditions(options)
      from_min_id(options[:min_id]).to_max_id(options[:max_id]).limit(options[:count]).order('posts.id DESC')
    end
  end
  has_many :user, through: :taggings

  def to_builder(options = {}, inclusion = {})
    bool_errors = self.errors.present?
    
    options.reverse_update(
      min_id: nil,
      max_id: nil,
      count: 10
    )

    inclusion.reverse_update(
      posts: false
    )

    Jbuilder.new do |json|
      json.data do |data|
        data.tag do |tag|
          tag.(self, :name, :posts_count)
          tag.tag_id self.id
          tag.posts(self.posts.find_with_conditions(options), :id, :caption, :editors_pick, :likes_count, :quote) if inclusion[:posts] and !bool_errors
        end
        
        if bool_errors
          data.errors self.errors.full_messages
        end
      end
      json.success !bool_errors
    end
  end
end
