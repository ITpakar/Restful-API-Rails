class RelationshipObserver < ActiveRecord::Observer
  def after_destroy(relationship)
    # decrement counts for user and follower
    relationship.user.decrement!(:followed_by_count)
    relationship.follower.decrement!(:follows_count)

    # SOLR: save changes to solr index
    relationship.user.index
    relationship.follower.index
    Sunspot.commit
  end
end