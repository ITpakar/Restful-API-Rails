class PostObserver < ActiveRecord::Observer
  def after_create(post)
    # RESQUE: save_tags_on_quote_and_caption
    Resque.enqueue(Jobs::ExtractTags, post.id)

    # increment posts counter on users
    user = post.user
    user.increment!(:posts_count)
  end

  def after_destroy(post)
    # decrement posts counter on tags
    post.tags.each do |tag|
      tag.decrement!(:posts_count)
    end

    # decrement posts counter on users
    user = post.user
    user.decrement!(:posts_count)
  end
end
