# == Schema Information
#
# Table name: quotes
#
#  id         :integer          not null, primary key
#  body       :text             default(""), not null
#  author_id  :integer
#  tags       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  source     :text
#

class Quote < ActiveRecord::Base
  attr_accessible :author_id, :body, :tags, :source

  belongs_to :author

  serialize :tags

  validates_presence_of :body

  searchable do
    string :author_name do
      author.name rescue ''
    end

    integer :author_id

    text :author_name, boost: 17.0
    text :source, boost: 2.0
    text :body, boost: 3.0
    text :tags, boost: 17.0
  end

  def author_name
    return author.name if author_id.present?
    return ''
  end
end
