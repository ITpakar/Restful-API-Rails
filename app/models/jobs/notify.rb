module Jobs
	class Notify
    @queue = :notify

    # alert_type - accepts symbol of the following
    #   new_follower
    #   fb_friend_joins
    #   likes_your_post
    #   comments_on_your_post
    #   comments_after_you
    #   requotes_your_post
    #   tagged_in_post
    #   post_gets_featured
    # user_ids - accepts an integer or a comma-separated string of IDs
    # actor_id - accepts integer or string of ID
    def self.perform(alert_type, user_ids, actor_id = nil)
      user_ids = user_ids.is_a?(Array) ? user_ids : user_ids.to_s.split(',')
      user_ids.each do |user_id|
        case alert_type.to_sym
        when :new_follower
          Activity.for_new_follower_to(user_id, actor_id)
        when :fb_friend_joins
          Activity.for_fb_friend_joins_to(user_id, actor_id)
        when :likes_your_post
          Activity.for_likes_your_post_to(user_id, actor_id)
        when :comments_on_your_post
          Activity.for_comments_on_your_post_to(user_id, actor_id)
        when :comments_after_you
          Activity.for_comments_after_you_to(user_id, actor_id)
        when :requotes_your_post
          Activity.for_requotes_your_post_to(user_id, actor_id)
        when :tagged_in_post
          Activity.for_tagged_in_post_to(user_id, actor_id)
        when :tagged_in_comment
          Activity.for_tagged_in_comment_to(user_id, actor_id)
        when :post_gets_featured
          Activity.for_post_gets_featured_to(user_id)
        end
      end
    end

  end
end