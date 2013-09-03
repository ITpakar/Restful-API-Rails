class Common

  def self.image_url(image, size = '')
    if image.present?
      image_path = size.present? ? image.thumb(size).url : image.jpg.url
      generate_image_url(image_path)
    else
      path = File.join(Rails.root, 'public', 'default-avatar.png')
      default = Dragonfly[:images].fetch_file(path)
      size.present? ? default.thumb(size).url : default.jpg.url
    end
  end

  def generate_image_url(image_path)
    if image_path.start_with?('http', 'https') or Rails.env.eql?('development')
      image_path
    else
      path, _, sha = image_path.split(/[\?\=]/)
      URI::HTTP.build({
        host: DEFAULT_HOST,
        path: path,
        query: {
          sha: sha
        }.to_param
      }).to_s
    end
  end

end