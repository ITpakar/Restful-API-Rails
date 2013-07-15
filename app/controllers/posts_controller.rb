class PostsController < ApplicationController
  def show
    @post = Post.find_by_created_at(Time.at(params[:id].to_i))
    @page_title = "Photo by #{@post.user.full_name} • "
    @ogtags = {
      title: "Photo by #{@post.user.full_name} | Quotiful",
      description: "#{@post.user.full_name}'s photo on Quotiful",
      web_url: post_url(@post.created_at.to_i),
      image_url: @post.quote_image_url
    }
    
    unless @post.present?
      redirect_to root_url, alert: "Photo not found."
      return
    end
  end
end
