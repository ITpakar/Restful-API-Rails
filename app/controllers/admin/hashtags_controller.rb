class Admin::HashtagsController < AdminController
  def index
    condition = params[:sort].present? and params[:sort].eql?(%(likes_count))
    sort = condition ? params[:sort].dup : 'name'
    
    if sort.eql?('likes_count')
      case params[:by]
      when 'today' then start_date = Time.zone.now.midnight
      when 'yesterday' then start_date = Time.zone.now.yesterday.midnight
      when 'last_week'
        start_date = Time.zone.now.prev_week
        end_date = Time.zone.now.prev_week.end_of_week
      when 'this_month' then start_date = Time.zone.now.beginning_of_month
      when 'this_year' then start_date = Time.zone.now.beginning_of_year
      else
        end_date = Time.zone.now
      end
    end
    
    tags = Tag.page(params[:page]).per(15)
    
    if start_date.present? or end_date.present?
      tags = tags.joins("LEFT OUTER JOIN `taggings` ON `taggings`.`tag_id` = `tags`.`id` AND `taggings`.`taggable_type` = 'Post' LEFT OUTER JOIN `posts` ON `posts`.`id` = `taggings`.`taggable_id`").order('COUNT(posts.id) DESC, name ASC')
    else
      tags = tags.order('name ASC')
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
