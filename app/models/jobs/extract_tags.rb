module Jobs
  class ExtractTags
    @queue = :extract_tags

    def self.perform(post_id)
      post = Post.find(post_id)
      quote = post.quote.split.find_all{|word| /^#.+/.match word}
      caption = post.caption.split.find_all{|word| /^#.+/.match word}
      hashtags = quote | caption
      hashtags.each do |hashtag|
        name = hashtag.delete('#').downcase
        tag = Tag.find_or_initialize_by_name(name)
        tag.increment(:posts_count)
        tag.save

        tagging = post.taggings.find_or_create_by_tag_id(tag_id: tag.id, user_id: post.user_id)
      end
    end
  end
end