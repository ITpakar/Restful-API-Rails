class PostObserver < ActiveRecord::Observer
  def after_create(post)
    # RESQUE: save_tags_on_quote_and_caption
    Resque.enqueue(Jobs::ExtractTags, post.id)

    # increment posts counter on users
    user = post.user
    user.increment!(:posts_count)

    # SOLR: add to solr index
    post.index!

    # RESQUE: Send APN alert for tagged users in post
    unless post.tagged_users.blank?
      user_ids = post.tagged_users.keys.join(',')
      Resque.enqueue(Jobs::Notify, :tagged_in_post, user_ids, user.id)
    end

    # RESQUE: Send APN alert for original author of the post
    unless post.origin_id.blank?
      author_id = post.origin.user_id
      Resque.enqueue(Jobs::Notify, :requotes_your_post, author_id, user.id)
    end
  end

  def after_destroy(post)
    # decrement posts counter on tags
    post.tags.each do |tag|
      tag.decrement!(:posts_count)
    end

    # decrement posts counter on users
    user = post.user
    user.decrement!(:posts_count)

    # SOLR: remove from solr index
    post.remove_from_index!
  end
end
