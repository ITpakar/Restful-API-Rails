require "em-synchrony"
require "em-synchrony/fiber_iterator"
require "thread"

module Response
  class Object
    include Rails.application.routes.url_helpers

    attr_accessor :class_name, :object, :options

    def initialize(class_name = '', object = nil, options = {})
      @class_name = class_name
      @object = object
      @options = options
    end

    def inspect
      object
    end

    def success
      @success ||= options[:success] || !errors.present?
    end

    def errors
      full_messages = (object.present? and !object.is_a?(Hash)) ? object.errors.full_messages : []
      @errors ||= options[:errors] || full_messages
    end

    def to_hash
      EM.synchrony do
        @hash = {}
        @hash[:data] = {}
        if class_name.present?
          @hash[:data][class_name.to_sym] = send("#{class_name}_hash")
          @hash[:errors] = errors if errors.present?
        else
          @hash[:data] = object if object.present?
        end
        @hash[:success] = success
        
        EM.stop
      end

      return @hash
    end

    def to_json
      @json = to_hash.to_json

      return @json
    end

    def relative_user
      @relative_user ||= User.find(options[:relative_user_id]) if options[:relative_user_id].present?
    end

    def current_user
      @current_user ||= User.find(options[:current_user_id]) if options[:current_user_id].present?
    end

    def activity_hash(activity = object)
      return {} unless activity.is_a?(Activity)

      hash = {
        body: activity.body,
        identifier: activity.custom_payloads.symbolize_keys[:identifier],
        timestamp: activity.created_at.to_i,
        details: activity.tagged_details
      }

      return hash
    end

    def author_hash(author = object)
      return {} unless author.is_a?(Activity)

      hash = {
        id: author.id,
        author_id: author.id,
        name: author.name
      }

      return hash
    end

    def post_hash(post = object)
      return {} unless post.is_a?(Post)

      hash = {
        post_id: post.id,
        quote: post.quote,
        quote_image_url: post.quote_image_url,
        author_name: post.author_name,
        caption: post.caption,
        description: post.description,
        editors_pick: post.editors_pick,
        likes_count: post.likes.count,
        posted_at: post.created_at.to_i,
        web_url: post_url(post.created_at.to_i, host: DEFAULT_HOST),
        background_image_url: post.background_image_url,
        quote_attr: post.quote_attr,
        author_attr: post.author_attr,
        quotebox_attr: post.quotebox_attr,
        origin_id: post.origin_id,
        tagged_users: post.tagged_users,
        s_thumbnail_url: post.quote_image_url('28x28#'),
        m_thumbnail_url: post.quote_image_url('70x70#'),
        flagged_count: post.flagged_count,
        user: user_hash(post.user)
      }

      if options[:current_user_id].present?
        hash.update({
          user_liked: post.liked_by?(options[:current_user_id]),
          in_collection: post.in_collection_of?(options[:current_user_id])
        })
      end

      return hash
    end

    def user_hash(user = object)
      return {} unless user.is_a?(User)

      hash = {
        user_id: user.id,
        full_name: user.full_name,
        profile_picture_url: user.profile_picture_url,
        s_thumbnail_url: user.profile_picture_url('20x20#'),
        m_thumbnail_url: user.profile_picture_url('70x70#'),
        favorite_quote: user.favorite_quote,
        author_name: user.author_name,
        website: user.website,
        follows_count: user.follows.count,
        followed_by_count: user.followers.count,
        posts_count: user.posts.count,
        collection_count: user.collections.count,
        birth_date: user.birth_date,
        gender: user.gender,
        active: user.active
      }

      if current_user.present? and user.id == current_user.id
        hash.update({
          notifications: user.notifications,
          email: user.email,
          authentication_token: user.authentication_token,
          badge_count: user.activities.unread.count
        })
      elsif current_user.present? and user.id != current_user.id
        hash.update({
          following_me: current_user.following_me?(user.id),
          following_date: current_user.following_date(user.id),
          am_follower: current_user.am_follower?(user.id),
          follower_date: current_user.follower_date(user.id)
        })
      end

      return hash
    end

  end
end