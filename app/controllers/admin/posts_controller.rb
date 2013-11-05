class Admin::PostsController < AdminController
  def index
    start_date, end_date = time_range_logic(params[:by]) if sort_by.eql?('likes_count')
    
    sort_str = "#{sort_by} DESC"

    query = params[:q]
    page = params[:page] || 1

    # posts = Post.order(sort_str).order('created_at DESC').page(params[:page]).per(20)

    # if end_date.present? 
    #   posts = posts.where("created_at <= ?", end_date)
    # end

    # if start_date.present?
    #   posts = posts.where("created_at >= ?", start_date)
    # end

    posts = Post.search do
      fulltext(query) do
        fields :user_name
      end

      with(:created_at).less_than(end_date) if end_date.present?
      with(:created_at).greater_than(start_date) if start_date.present?

      paginate(page: page, per_page: 20)

      order_by(sort_by.to_sym, :desc)
      order_by(:created_at, :desc)
    end.results
    
    @posts = posts
  end

  def update
    post = Post.find(params[:id])
    if params[:pick].eql?('true')
      post.pick!
    else
      post.unpick!
    end

    redirect_to :back, page: params[:page], sort: params[:sort], by: params[:by]
  end

  def destroy
    post = Post.find(params[:id])
    user = post.user
    post.destroy
    Posts::Mailer.deleted_post(user.id).deliver

    redirect_to :back, page: params[:page], sort: params[:sort]
  end

  def flagged
    @posts = Post.flagged.order([sort_by, 'desc'].join(' '), 'created_at desc').page(params[:page]).per(20)
  end

  private

    def sort_by
      %w(editors_pick likes_count flagged_count).include?(params[:sort]) ? params[:sort] : 'created_at'
    end
end