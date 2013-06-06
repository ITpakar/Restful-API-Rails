class Admin::UsersController < AdminController
  def index
    @users = User.page(params[:page]).per(15).order("full_name ASC, email ASC")
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    
    if @user.update_attributes(params[:user])
      redirect_to :back, notice: "Successfully updated the user information."
    else
      messages = @users.errors.full_messages.dup
      messages << nil

      redirect_to :back, alert: messages.join('. ')
    end
  end

  def reactivate
    user = User.find(params[:id])
    user.reactivate!

    redirect_to admin_users_url(page: params[:page]), notice: "Successfully reactivated the user."
  end

  def destroy
    user = User.find(params[:id])
    user.deactivate!

    redirect_to admin_users_url(page: params[:page]), notice: "Successfully deactivated the user."
  end
end
