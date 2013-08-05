module Users
  class PasswordsController < ApplicationController
    layout 'users'

    def edit
      @user = User.new
      @user.reset_password_token = params[:reset_password_token]
    end

    def update
      @user = User.reset_password_by_token(params[:user])

      if @user.errors.empty?
        @user.update_attribute(:has_password, true)
        redirect_to complete_users_passwords_url(full_name: @user.full_name)
      else
        redirect_to :back
      end
    end

  end
end
