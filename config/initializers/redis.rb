rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'
redis_config = YAML.load_file(rails_root + 'config/redis.yml')

$redis = Redis.new(redis_config[rails_env])