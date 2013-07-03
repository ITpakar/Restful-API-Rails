class LikeObserver < ActiveRecord::Observer
  def after_create(like)
    # increment likes counter on likable
    likable = like.likable
    likable.increment!(:likes_count)
  end

  def before_destroy(like)
    # decrement likes counter on likable
    likable = like.likable
    likable.decrement!(:likes_count)
  end
end
