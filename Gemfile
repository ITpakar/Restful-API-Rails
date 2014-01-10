source 'https://rubygems.org'

gem 'rails', '3.2.13'
# gem 'mysql2'
# changed to pg due to unable to store emoji characters
gem 'pg', '~> 0.16.0'

gem 'api-versions', '~> 0.2.0'
gem 'hashie', '~> 2.0.4'
gem 'kaminari', '~> 0.14.1'
gem 'roo', git: 'https://github.com/Empact/roo.git'
gem 'database_cleaner', '~> 1.0.1'

gem 'slim', '~> 2.0.0'
gem 'jquery-rails', '~> 3.0.0'

# gem 'dragonfly', '~>0.9.15'
gem 'dragonfly', '~>1.0'
gem 'dragonfly-s3_data_store'
gem 'dalli', '~> 2.6.4' # memcache client
gem 'kgio', '~> 2.8.1' # non-blocking i/o gives dalli 10-20% speed boost
gem 'rack-cache', :require => 'rack/cache'

gem 'devise', '~> 2.2.4'
gem 'doorkeeper', '~> 0.6.7'
gem 'ledermann-rails-settings', :require => 'rails-settings'

gem 'resque', '~> 1.24.1'
gem 'em-synchrony', '~> 1.0.3'
gem 'activerecord-import', '~> 0.2.11'

gem 'sunspot_rails', '~> 2.0.0'
gem 'sunspot_solr', '~> 2.0.0'
gem 'progress_bar', '~> 1.0.0'

gem 'grocer'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
  gem 'less-rails', '~> 2.3.3'
  gem 'twitter-bootstrap-rails', '~> 2.2.6'
  gem 'fog', '~> 1.15.0'
  gem 'asset_sync', '~> 1.0.0'
end

group :development do
  gem 'pry'
  gem 'annotate'
end