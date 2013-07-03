class PostsController < ApplicationController
  def show
    @post = Post.find_by_created_at(Time.at(params[:id].to_i))
    
    unless @post.present?
      redirect_to root_url, alert: "No image found."
      return
    end
  end
end
