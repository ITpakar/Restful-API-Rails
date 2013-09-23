class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    unless comment.tagged_users.blank?
      user = comment.user

      user_ids = comment.tagged_users.keys
      Resque.enqueue(Jobs::Notify, :tagged_in_comment, user_ids, user.id, {comment_id: comment.id, post_id: comment.commentable_id})
    end
  end
end