require 'dragonfly'

app = Dragonfly[:images]
app.configure_with(:imagemagick)
app.configure_with(:rails)

app.define_macro(ActiveRecord::Base, :image_accessor)

Dragonfly[:images].configure do |c|
  c.allow_fetch_file = true
  c.protect_from_dos_attacks = true
end

if Rails.env == 'production'
  app.datastore = Dragonfly::DataStorage::S3DataStore.new

  app.datastore.configure do |c|
    c.bucket_name = 'nicephore'
    c.access_key_id = 'AKIAJ5PJULN75BYPMHTQ'
    c.secret_access_key = 'iz0qp0zeUIHelqRb7EjAUafh7U38j5'
    # c.region = 'eu-west-1'                        # defaults to 'us-east-1'
    # c.storage_headers = {'some' => 'thing'}       # defaults to {'x-amz-acl' => 'public-read'}
    # c.url_scheme = 'https'                        # defaults to 'http'
    # c.url_host = 'some.custom.host'               # defaults to "<bucket_name>.s3.amazonaws.com"
  end
end