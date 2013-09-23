class PostsController < ApplicationController
  def show
    # for mysql, working
    # @post = Post.find_by_created_at(Time.at(params[:id].to_i))
    # for postgresql, not working
    # @post = Post.where("posts.created_at::timestamp = timestamp ?", Time.at(params[:id].to_i).to_s(:db)).first
    @post = Post.find_by_posted_at(params[:id])
    
    unless @post.present?
      render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found
      return
    else
      @page_title = "Photo by #{@post.user.full_name} | "
      image_path = @post.quote_image_url
      host = Rails.env.development? ? 'http://localhost:3000' : URI::HTTP.build({host: DEFAULT_HOST})
      @ogtags = {
        title: "Photo by #{@post.user.full_name} | Quotiful",
        description: "#{@post.user.full_name}'s photo on Quotiful",
        web_url: post_url(@post.created_at.to_i),
        image_url: host + image_path
      }
    end
  end
end
