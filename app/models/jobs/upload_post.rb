module Jobs
  class UploadPost
    @queue = :upload

    def self.perform(post_id)
      post = Post.find(post_id)

      images = Response::Object.new('post', post).to_hash[:data][:post].values_at(:s_thumbnail_url, :m_thumbnail_url, :quote_image_url).delete_if {|u| u.starts_with?("http://d1t4f9gbrjiu98.cloudfront.net/")}

      images.each do |image|
        url = URI.parse(image)
        open(url) do |http|
          response = http.read
          puts "response: #{response.inspect}"
        end
      end
    end
  end
end