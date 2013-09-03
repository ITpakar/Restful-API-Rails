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
    # c.storage_headers = {'some' => 'thing'}       # defaults to {'x-amz-acl' => 'public-read'}
    # c.url_scheme = 'https'                        # defaults to 'http'
    # c.url_host = 'some.custom.host'               # defaults to "<bucket_name>.s3.amazonaws.com"
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
  end
end