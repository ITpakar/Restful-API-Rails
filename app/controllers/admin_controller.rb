class AdminController < ApplicationController
  before_filter :authenticate_admin!

  def index
    if admin_signed_in?
      redirect_to admin_preset_images_url
    end
  end
end
