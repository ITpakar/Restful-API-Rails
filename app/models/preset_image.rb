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