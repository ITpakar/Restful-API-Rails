class CollectionObserver < ActiveRecord::Observer
  def after_create(collection)
    user = collection.user
    user.increment!(:collection_count)

    post = collection.post

    Resque.enqueue(Jobs::Notify, :saves_your_quotiful, post.user_id, user.id, {post_id: post.id})
  end

  def before_destroy(collection)
    user = collection.user
    user.decrement!(:collection_count)
  end
end
