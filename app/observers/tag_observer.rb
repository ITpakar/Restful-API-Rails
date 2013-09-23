class TagObserver < ActiveRecord::Observer
  def after_save(tag)
    # SOLR: add to solr index
    tag.index!
  end

  def after_destroy(tag)
    # SOLR: remove from solr index
    tag.remove_from_index!
  end
end
