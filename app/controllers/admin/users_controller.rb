class Admin::UsersController < AdminController
  def index
    @users = User.page(params[:page]).per(20)
  end

  def destroy
    user = User.find(params[:id])
    user.deactivate!

    redirect_to admin_users_url
  end
end
