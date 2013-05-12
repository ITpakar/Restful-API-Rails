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

  validates_presence_of :quote#, :quote_image

  after_save :save_tags_on_quote_and_description

  image_accessor :quote_image

  def to_builder
    bool_errors = self.errors.present?
    Jbuilder.new do |json|
      json.data do |data|
        data.post do |post|
          post.(self, :caption, :editors_pick, :likes_count, :quote)
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
      # json.status (bool_errors ? 422 : 201)
    end
  end

  private

    def save_tags_on_quote_and_description
      # TODO: Resque job for searching tags on quotes and description
    end
end
