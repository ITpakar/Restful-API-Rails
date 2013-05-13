class PostObserver < ActiveRecord::Observer
  def after_create(post)
    # RESQUE: save_tags_on_quote_and_caption
    Resque.enqueue(Jobs::ExtractTags, post.id)
  end

  def before_destroy(post)
    post.tags.each do |tag|
      tag.decrement!(:posts_count)
    end
  end
end
