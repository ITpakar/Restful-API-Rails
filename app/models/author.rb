# == Schema Information
#
# Table name: authors
#
#  id         :integer          not null, primary key
#  name       :string(255)      default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Author < ActiveRecord::Base
  attr_accessible :name, :first_name, :last_name

  has_many :quotes, dependent: :nullify

  validates_presence_of :name

  searchable do
    string :name
    text :name
  end
end
