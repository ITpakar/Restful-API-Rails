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
    def paginate_by(count = 10, condition = '')
      where(condition).limit(count).order('posts.id DESC')
    end
  end
  has_many :user, through: :taggings

  def to_builder(with_posts = false, options = {min_id: nil, max_id: nil})
    bool_errors = self.errors.present?
    Jbuilder.new do |json|
      json.data do |data|
        data.tag do |tag|
          tag.(self, :name, :posts_count)
          tag.tag_id self.id
          
          if with_posts
            arr_condition = []
            arr_condition << "posts.id > %s" % options[:min_id] if options[:min_id].present?
            arr_condition << "posts.id < %s" % options[:max_id] if options[:max_id].present?
            str_condition = arr_condition.join(" AND ")
            tag.posts self.posts.paginate_by(10, str_condition), :id, :caption, :editors_pick, :likes_count, :quote

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
