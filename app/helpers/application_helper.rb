module ApplicationHelper
  def alert_class
    if notice.present?
      'alert-success'
    elsif alert.present?
      'alert-error'
    else
      return
    end
  end

  def alert_header
    if notice.present?
      "Well done!"
    elsif alert.present?
      "Oh snap!"
    else
      "Warning!"
    end
  end

  def alert_message
    if notice.present?
      notice
    elsif alert.present?
      alert
    end
  end

  def placeholder_image_path(size = '')
    path = File.join(Rails.root, 'public', 'default.png')
    default = Dragonfly.app.fetch_file(path)
    size.present? ? default.thumb(size).url : default.jpg.url
  end
end
