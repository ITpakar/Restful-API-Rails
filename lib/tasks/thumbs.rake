require 'open-uri'
require "em-synchrony"
require "em-synchrony/fiber_iterator"
require "thread"

namespace :thumbs do
  desc "Process thumbnails uploading to s3"
  task :process_upload => :environment do
    posts = Post.where("created_at >= ?", Date.yesterday).order("created_at ASC")
    users = User.where("created_at >= ?", Date.yesterday).order("created_at ASC")
    
    images = Response::Collection.new('post', posts).to_hash[:data][:posts].collect {|p| [p[:s_thumbnail_url], p[:m_thumbnail_url], p[:quote_image_url]]}.flatten.delete_if {|u| u.starts_with?("http://d1t4f9gbrjiu98.cloudfront.net/")}
    images += Response::Collection.new('user', users).to_hash[:data][:users].collect {|p| [p[:s_thumbnail_url], p[:m_thumbnail_url], p[:profile_picture_url]]}.flatten.delete_if {|u| u.starts_with?("http://d1t4f9gbrjiu98.cloudfront.net/")}

    puts images.count

    EM.synchrony do
      EM::Synchrony::FiberIterator.new(images, 20).each do |image|
        url = URI.parse(image)
        open(url) do |http|
          response = http.read
          puts "response: #{response.inspect}"
        end
      end
      EM.stop
    end
  end
end