require 'resque/server'

rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'
resque_config = YAML.load_file(rails_root + 'config/resque.yml')
redis_config = YAML.load_file(rails_root + 'config/redis.yml')
Resque.redis = "#{redis_config[rails_env]['host']}:#{redis_config[rails_env]['port']}"
Resque.redis.namespace = "quotiful:#{rails_env}:resque"

Resque::Server.class_eval do
  use Rack::Auth::Basic do |username, password|
    username == "quotiful01" && password == "quotiful123"
  end
end

Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }