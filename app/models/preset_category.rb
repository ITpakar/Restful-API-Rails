# == Schema Information
#
# Table name: preset_categories
#
#  id                  :integer          not null, primary key
#  preset_images_count :integer          default(0), not null
#  name                :string(255)      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class PresetCategory < ActiveRecord::Base
  attr_accessible :name, :preset_images_count

  has_many :preset_images, dependent: :nullify

  validates_presence_of :name

  def preset_image_sample
    image = self.preset_images.primary.first

    unless image.present?
      image = self.preset_images.order('name ASC').first
    end

    if image.present?
      image.preset_image_url('75x75#')
    else
      ''
    end
  end

  def set_primary!(preset_image_id)
    preset_images.primary.update_all(primary: false)
    preset_images.update_all({primary: true}, {id: preset_image_id})
  end

end
