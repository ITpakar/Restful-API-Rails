class Admin::PostsController < AdminController
  def index
    condition = params[:sort].present? and params[:sort].in?(%w(editors_pick likes_count))
    
    if sort_by.eql?('likes_count')
      case params[:by]
      when 'today' then start_date = Time.zone.now.midnight
      when 'yesterday'
        start_date = Time.zone.now.yesterday.midnight
        end_date = Time.zone.now.midnight
      when 'last_week'
        start_date = Time.zone.now.prev_week
        end_date = Time.zone.now.prev_week.end_of_week
      when 'this_month' then start_date = Time.zone.now.beginning_of_month
      when 'this_year' then start_date = Time.zone.now.beginning_of_year
      else
        end_date = Time.zone.now
      end
    end
    
    posts = Post.order(sort_by.to_sym => :desc, created_at: :desc).page(params[:page]).per(20)
    
    if end_date.present? 
      posts = posts.where("created_at <= ?", end_date)
    end

    if start_date.present?
      posts = posts.where("created_at >= ?", start_date)
    end
    
    @posts = posts
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

  def destroy
    post = Post.find(params[:id])
    user = post.user
    post.destroy
    Posts::Mailer.deleted_post(user.id).deliver

    redirect_to :back, page: params[:page], sort: params[:sort]
  end

  def flagged
    condition = params[:sort].present? and params[:sort].in?(%w(editors_pick likes_count))
    
    @posts = Post.flagged.order(sort_by.to_sym => :desc, created_at: :desc).page(params[:page]).per(20)
  end

  private

    def sort_by
      %w(editors_pick likes_count).include?(params[:sort]) ? params[:sort] : 'created_at'
    end
end