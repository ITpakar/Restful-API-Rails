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
  attr_accessible :preset_category_id, :name, :preset_image

  belongs_to :preset_category, :counter_cache => true

  image_accessor :preset_image

  validates_presence_of :preset_image

  scope :unassigned, where(preset_category_id: nil).order('updated_at DESC')

  def assign!(category_id)
    # category = PresetCategory.find(category_id)
    # category.increment!(:preset_images_count)
    self.update_attribute(:preset_category_id, category_id)
    PresetCategory.reset_counters category_id, :preset_images
  end

  def unassign!
    category = self.preset_category
    # category.decrement!(:preset_images_count)
    self.update_attribute(:preset_category_id, nil)
    PresetCategory.reset_counters category.id, :preset_images
  end

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
