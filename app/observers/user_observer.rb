class UserObserver < ActiveRecord::Observer
  def after_save(user)
    # SOLR: add to solr index
    user.index!
  end

  def after_destroy(user)
    # SOLR: remove from solr index
    user.remove_from_index!
  end
end
