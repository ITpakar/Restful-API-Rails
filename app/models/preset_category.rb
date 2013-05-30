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

  has_many :preset_images

  def to_builder
    Jbuilder.new do |json|
      json.data do |data|
        data.category do |category|
          category.(self, :name, :preset_images_count)
          category.category_id self.id
          category.images do |image|
            image.array! self.preset_images do |preset_image|
              image.image_id preset_image.id
              image.image_url preset_image.preset_image.url
            end
          end 
        end
      end
      json.success true
    end
  end
end
