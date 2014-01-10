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
#  primary            :boolean          default(FALSE), not null
#

class PresetImage < ActiveRecord::Base
  attr_accessible :preset_category_id, :name, :preset_image

  belongs_to :preset_category, :counter_cache => true

  # image_accessor :preset_image
  dragonfly_accessor :preset_image do
    default 'public/default-avatar.png'
    after_assign do |i|
      i.thumb('56x56#')
      i.thumb('140x140#')
    end
  end

  validates_presence_of :preset_image

  scope :primary, where(primary: true)
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

  def preset_image_url(size = '')
    Common.image_url(preset_image, size)
  end

  def preset_category_name
    if self.preset_category.present?
      self.preset_category.name
    else
      ''
    end
  end

end
