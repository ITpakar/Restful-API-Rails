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

    def post_hash(object = object)
      return {} unless object.is_a?(Post)

      hash = {
        post_id: object.id,
        quote: object.quote,
        quote_image_url: object.quote_image_url,
        author_name: object.author_name,
        caption: object.caption,
        description: object.description,
        editors_pick: object.editors_pick,
        likes_count: object.likes.count,
        posted_at: object.created_at.to_i,
        web_url: post_url(object.created_at.to_i, host: DEFAULT_HOST),
        background_image_url: object.background_image_url,
        quote_attr: object.quote_attr,
        author_attr: object.author_attr,
        quotebox_attr: object.quotebox_attr,
        origin_id: object.origin_id,
        tagged_users: object.tagged_users,
        s_thumbnail_url: object.quote_image_url('28x28#'),
        m_thumbnail_url: object.quote_image_url('70x70#'),
        flagged_count: object.flagged_count,
        user: user_hash(object.user)
      }

      if options[:current_user_id].present?
        hash.update({
          user_liked: object.liked_by?(options[:current_user_id]),
          in_collection: object.in_collection_of?(options[:current_user_id])
        })
      end

      return hash
    end

    def user_hash(object = object)
      return {} unless object.is_a?(User)

      hash = {
        user_id: object.id,
        full_name: object.full_name,
        profile_picture_url: object.profile_picture_url,
        s_thumbnail_url: object.profile_picture_url('20x20#'),
        m_thumbnail_url: object.profile_picture_url('70x70#'),
        favorite_quote: object.favorite_quote,
        author_name: object.author_name,
        website: object.website,
        follows_count: object.follows.count,
        followed_by_count: object.followers.count,
        posts_count: object.posts.count,
        collection_count: object.collections.count,
        birth_date: object.birth_date,
        gender: object.gender,
        active: object.active
      }

      if current_user.present? and object.id == current_user.id
        hash.update({
          notifications: object.notifications,
          email: object.email,
          authentication_token: object.authentication_token,
          badge_count: object.activities.unread.count
        })
      elsif current_user.present? and object.id != current_user.id
        hash.update({
          following_me: current_user.following_me?(object.id),
          following_date: current_user.following_date(object.id),
          am_follower: current_user.am_follower?(object.id),
          follower_date: current_user.follower_date(object.id)
        })
      end

      return hash
    end

  end
end