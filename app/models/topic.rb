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
  NAMES = %w(Love Life Happiness Success Wisdom Dreams Imagination Inspiration Motivation Positive Passion Courage Change Confidence Beauty Failure Fear Friendship Relationships Breakups Funny Art Design Creativity Fashion Technology Music Sports Business Entrepreneurship Travel Celebrities Movies Books Nature)
  
  attr_accessible :name

  has_and_belongs_to_many :quotes, uniq: true

  searchable do
    string :name
    text :name
  end

  scope :explore, where(name: NAMES)
end
