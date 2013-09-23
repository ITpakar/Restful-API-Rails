# == Schema Information
#
# Table name: devices
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  device_token :string(255)      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Device < ActiveRecord::Base
  attr_accessible :device_token, :user_id

  belongs_to :user

  validates :device_token, presence: true, uniqueness: true

  def self.signs_out_in(device_token)
    if device_token.present?
      device = self.find_or_initialize_by_device_token(device_token)
      device.user = nil
      device.save
    end
  end
end
