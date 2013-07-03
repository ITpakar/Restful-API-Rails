class QuoteObserver < ActiveRecord::Observer
  def after_save(quote)
    # SOLR: add to solr index
    quote.index!
  end

  def after_destroy(quote)
    # SOLR: remove from solr index
    quote.remove_from_index!
  end
end
