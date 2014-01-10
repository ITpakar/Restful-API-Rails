require 'dragonfly'
require 'dragonfly/s3_data_store'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  allow_legacy_urls true
  protect_from_dos_attacks true
  secret "659b5f82190fe1df02f5a4817b1591d8aac3de26b5422251c52f03d9d7941b2ae564bf1505a5aaa72cb26e000f9a6cf6417bfee1a86c3e9e36dc3845f7ef5e7c"

  url_format "/media/:job/:name"

  fetch_file_whitelist [
    /public/
  ]

  response_header "Cache-Control", "public, max-age=3600"

  if Rails.env == 'production'
    datastore :s3,
      bucket_name: 'nicephore',
      access_key_id: 'AKIAJ5PJULN75BYPMHTQ',
      secret_access_key: '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',
      url_host: 'd1t4f9gbrjiu98.cloudfront.net',
      storage_headers: {'x-amz-acl' => 'private'}

    # Override the .url method...
    define_url do |app, job, opts|
      thumb = Thumb.find_by_signature(job.signature)
      # If (fetch 'some_uid' then resize to '40x40') has been stored already, give the datastore's remote url ...
      if thumb
        app.datastore.url_for(thumb.uid)
      # ...otherwise give the local Dragonfly server url
      else
        app.server.url_for(job)
      end
    end

    # Before serving from the local Dragonfly server...
    before_serve do |job, env|
      # ...store the thumbnail in the datastore...
      uid = job.store

      # ...keep track of its uid so next time we can serve directly from the datastore
      Thumb.create!(uid: uid, signature: job.signature)
    end
  else
    datastore :file,
      root_path: Rails.root.join('public/system/dragonfly', Rails.env),
      server_root: Rails.root.join('public')
  end
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
