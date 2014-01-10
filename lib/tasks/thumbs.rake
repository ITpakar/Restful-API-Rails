require 'open-uri'
require "em-synchrony"
require "em-synchrony/fiber_iterator"
require "thread"

namespace :thumbs do
  desc "Force upload post"
  task :force_upload => :environment do
    EM.synchrony do
      EM::Synchrony::FiberIterator.new(Post.all, 1000).each do |p|
        [p.quote_image.job, p.quote_image.thumb('56x56#'), p.quote_image.thumb('140x140#')].each do |job|
          thumb = Thumb.find_or_initialize_by_signature(job.signature)
          unless thumb.new_record?
            puts "skip Post##{p.id}"
            next
          end
          thumb.uid = job.store
          thumb.save
        end
        puts "uploaded Post##{p.id}"
      end

      EM::Synchrony::FiberIterator.new(PresentImage.all, 1000).each do |p|
        [p.preset_image.job, p.preset_image.thumb('56x56#'), p.preset_image.thumb('140x140#')].each do |job|
          thumb = Thumb.find_or_initialize_by_signature(job.signature)
          unless thumb.new_record?
            puts "skip PresetImage##{p.id}"
            next
          end
          thumb.uid = job.store
          thumb.save
        end
        puts "uploaded PresetImage##{p.id}"
      end
    
      EM::Synchrony::FiberIterator.new(User.all, 1000).each do |u|
        [u.profile_picture.job, u.profile_picture.thumb('56x56#'), u.profile_picture.thumb('140x140#')].each do |job|
          thumb = Thumb.find_or_initialize_by_signature(job.signature)
          unless thumb.new_record?
            puts "skip User##{u.id}"
            next
          end
          thumb.uid = job.store
          thumb.save
        end
        puts "uploaded User##{u.id}"
      end
      
      EM.stop
    end
  end

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