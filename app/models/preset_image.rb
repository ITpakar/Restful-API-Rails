# == Schema Information
#
# Table name: preset_images
#
#  id                 :integer          not null, primary key
#  preset_image_uid   :string(255)
#  preset_image_name  :string(255)
#  preset_category_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  name               :string(255)      default("")
#

class PresetImage < ActiveRecord::Base
  attr_accessible :preset_image_name, :preset_image_uid, :preset_category_id, :name

  belongs_to :preset_category, :counter_cache => true

  image_accessor :preset_image

  def to_builder
    Jbuilder.new do |json|
      json.data do |data|
        data.preset_image do |img|
          img.image_url self.preset_image.try(:url)
          img.category_name self.preset_category.try(:name)
          img.name self.name
        end
      end
      json.success true
    end
  end
end
