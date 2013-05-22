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
#

class Quote < ActiveRecord::Base
  attr_accessible :author_id, :body, :tags

  belongs_to :author

  serialize :tags

  validates_presence_of :body

  searchable do
    string :author_name do
      author.name
    end

    text :author_name do
      author.name
    end
  end
end
