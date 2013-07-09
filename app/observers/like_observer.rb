class LikeObserver < ActiveRecord::Observer
  def after_create(like)
    # increment likes counter on likable
    likable = like.likable
    
    user = likable.user
    liker = like.user

    Activity.for_likes_your_post_to(user.id, liker.id)
    
    likable.increment!(:likes_count)
  end

  def before_destroy(like)
    # decrement likes counter on likable
    likable = like.likable
    likable.decrement!(:likes_count)
  end
end
