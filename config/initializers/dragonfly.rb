require 'dragonfly'

app = Dragonfly[:images]
app.configure_with(:imagemagick)
app.configure_with(:rails)

app.define_macro(ActiveRecord::Base, :image_accessor)

app.configure do |c|
  c.allow_fetch_file = true
  c.protect_from_dos_attacks = true
end

if Rails.env == 'production'
  app.datastore = Dragonfly::DataStorage::S3DataStore.new

  app.datastore.configure do |c|
    c.bucket_name = 'nicephore'
    c.access_key_id = 'AKIAJ5PJULN75BYPMHTQ'
    c.secret_access_key = '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'
    # c.region = 'eu-west-1'                        # defaults to 'us-east-1'
    # c.url_scheme = 'https'                        # defaults to 'http'
    c.url_host = 'd1t4f9gbrjiu98.cloudfront.net'  # defaults to "<bucket_name>.s3.amazonaws.com"

    # Prohibit images from being accessed directly from S3 by the public.
    # In conjunction with protect_from_dos_attacks (see below), this allows
    # our rails app to enforce access, e.g. to allow access to a 64x64 thumbnail
    # but prohibit access to the original image.
    c.storage_headers = {'x-amz-acl' => 'private'}
  end

  app.configure do |c|
    # Override the .url method...
    c.define_url do |app, job, opts|
      thumb = Thumb.find_by_job(job.serialize)
      # If (fetch 'some_uid' then resize to '40x40') has been stored already, give the datastore's remote url ...
      if thumb
        app.datastore.url_for(thumb.uid)
      # ...otherwise give the local Dragonfly server url
      else
        app.server.url_for(job)
      end
    end

    # Before serving from the local Dragonfly server...
    c.server.before_serve do |job, env|
      # ...store the thumbnail in the datastore...
      uid = job.store

      # ...keep track of its uid so next time we can serve directly from the datastore
      Thumb.create!(
        :uid => uid,
        :job => job.serialize     # 'BAhbBls...' - holds all the job info
      )                           # e.g. fetch 'some_uid' then resize to '40x40'
    end
    # Make it effectively impossible to guess valid image URLs

    # Amazon CloudFront does not allow query params, so put sha in the url itself
    c.url_format = '/media/:job/:sha/:basename.:format'
    # This secret should be unique to your app. Use SecureRandom.hex(64) to make one.
    c.secret = '659b5f82190fe1df02f5a4817b1591d8aac3de26b5422251c52f03d9d7941b2ae564bf1505a5aaa72cb26e000f9a6cf6417bfee1a86c3e9e36dc3845f7ef5e7c'
  end
end