class AdminController < ApplicationController
  before_filter :authenticate_admin!
  
  def index
    if admin_signed_in?
      redirect_to admin_preset_images_url
    end
  end

  protected

    def time_range_logic(range)
      start_date = nil
      end_date = nil
      
      case range
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

      [start_date, end_date]
    end

end
