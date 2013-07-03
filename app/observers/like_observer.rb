class LikeObserver < ActiveRecord::Observer
  def after_create(like)
    # increment likes counter on likable
    likable = like.likable
    
    user = likable.user
    user_tokens = user.devices.map(&:device_token)
    user_tokens.each do |token|
      PushNotification.new(token, "#{like.user.full_name} liked your quote")
    end

    likable.increment!(:likes_count)
  end

  def before_destroy(like)
    # decrement likes counter on likable
    likable = like.likable
    likable.decrement!(:likes_count)
  end
end
