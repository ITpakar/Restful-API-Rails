# == Schema Information
#
# Table name: thumbs
#
#  id         :integer          not null, primary key
#  uid        :string(255)
#  job        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Thumb < ActiveRecord::Base
  attr_accessible :job, :uid, :signature
end
