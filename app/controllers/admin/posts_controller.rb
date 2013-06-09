class Admin::PostsController < AdminController
  def index
    condition = params[:sort].present? and params[:sort].in?(%(editors_pick likes_count))
    sort = condition ? params[:sort].dup : 'created_at'
    @posts = Post.order("#{sort} DESC, created_at DESC").page(params[:page]).per(20)
  end

  def update
    post = Post.find(params[:id])
    if params[:pick].eql?('true')
      post.pick!
    else
      post.unpick!
    end

    redirect_to admin_posts_path(page: params[:page], sort: params[:sort])
  end
end
