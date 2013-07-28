require "em-synchrony"
require "em-synchrony/fiber_iterator"
require "thread"

module Response
  class Collection
    include Rails.application.routes.url_helpers

    attr_accessor :class_name, :collection, :options

    # options:
    # alt_key - alternative hash key for json
    # instance_user_id - user ID to show details of a user
    # page - current page number
    # success - actual response status
    def initialize(class_name = '', collection = [], options = {})
      @class_name = class_name
      @collection = collection
      @options = options
    end

    def inspect
      class_name.classify.constantize.new
    end

    def success
      @success ||= options[:success] || true
    end

    def to_hash
      EM.synchrony do
        @hash = {}
        @hash[:data] = {}
        key = options[:alt_key].present? ? options[:alt_key].to_sym : class_name.pluralize.to_sym
        @hash[:data][key] = collective_hash if class_name.present?
        @hash[:data][:user] = Response::Object.new('user', instance_user, options).user_hash if instance_user.present?
        @hash[:data][:page] = options[:page] || 1
        @hash[:success] = success

        EM.stop
      end

      return @hash
    end

    def to_json
      @json = to_hash.to_json

      return @json
    end

    def instance_user
      @instance_user ||= User.find(options[:instance_user_id]) if options[:instance_user_id].present?
    end

    def collective_hash
      array = []

      collection.each do |object|
        array << Response::Object.new(class_name, object, options).send("#{class_name}_hash")
      end

      return array
    end

  end
end