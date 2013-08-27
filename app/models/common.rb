class Common

  def self.image_url(image, size = '')
    if image.present?
      # size.present? ? image.thumb(size).remote_url : image.jpg.remote_url
      image.remote_url
    else
      path = File.join(Rails.root, 'public', 'default-avatar.png')
      default = Dragonfly[:images].fetch_file(path)
      size.present? ? default.thumb(size).url : default.jpg.url
    end
  end

end