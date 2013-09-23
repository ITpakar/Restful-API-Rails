class Admin::HashtagsController < AdminController
  def index
    condition = params[:sort].present? and params[:sort].eql?(%(likes_count))
    sort = condition ? params[:sort].dup : 'name'
    
    start_date, end_date = time_range_logic(params[:by]) if sort.eql?('likes_count')
    
    tags = Tag.page(params[:page]).per(15)
    
    if start_date.present? or end_date.present?
      tags = tags.joins("LEFT OUTER JOIN taggings ON taggings.tag_id = tags.id AND taggings.taggable_type = 'Post' LEFT OUTER JOIN posts ON posts.id = taggings.taggable_id").group("tags.id").order('posts_ctr DESC, name ASC').select("COUNT(DISTINCT(posts.id)) AS posts_ctr, tags.*")
    else
      tags = tags.order('name ASC').select("tags.posts_count AS posts_ctr, tags.*")
    end

    if end_date.present? 
      tags = tags.where("posts.created_at <= ?", end_date)
    end

    if start_date.present?
      tags = tags.where("posts.created_at >= ?", start_date)
    end

    @tags = tags
  end

  def show
    @tag = Tag.find(params[:id])
    @posts = @tag.posts.order('posts.created_at DESC').page(params[:page]).per(15)
  end
end
