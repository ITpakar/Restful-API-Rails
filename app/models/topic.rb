# == Schema Information
#
# Table name: topics
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Topic < ActiveRecord::Base
  attr_accessible :name

  has_and_belongs_to_many :quotes, uniq: true

  searchable do
    string :name
    text :name
  end
end
