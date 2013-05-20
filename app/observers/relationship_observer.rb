class RelationshipObserver < ActiveRecord::Observer
  def after_destroy(relationship)
    relationship.user.decrement!(:followed_by_count)
    relationship.follower.decrement!(:follows_count)
  end
end