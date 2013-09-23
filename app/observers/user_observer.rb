class UserObserver < ActiveRecord::Observer
  def after_create(user)
    quotiful = User.where(email: 'info@quotiful.com').first
    if quotiful.present? and quotiful != user
      user.followed_by_users << quotiful
    end
  end

  def after_save(user)
    # SOLR: add to solr index
    user.index!
  end

  def after_destroy(user)
    # SOLR: remove from solr index
    user.remove_from_index!
  end
end
