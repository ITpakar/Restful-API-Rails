module AdminHelper
  def currently_sorted_by?(expected, actual)
    str = expected.gsub('_', ' ')
    if expected.eql?(actual) or (expected.eql?('all_time') and actual.blank?)
      "#{content_tag(:i, '', :class => 'icon-arrow-down')} #{str}".html_safe
    else
      str.html_safe
    end
  end
end
