class Admin::HashtagsController < AdminController
  def index
    @tags = Tag.page(params[:page]).per(15).order('name ASC, posts_count ASC')
  end

  def show
    @tag = Tag.find(params[:id])
    @posts = @tag.posts.order('posts.created_at DESC').page(params[:page]).per(15)
  end
end
