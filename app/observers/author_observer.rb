class AuthorObserver < ActiveRecord::Observer
  def after_save(author)
    # SOLR: add to solr index
    author.index!
  end

  def after_destroy(author)
    # SOLR: remove from solr index
    author.remove_from_index!
  end
end
