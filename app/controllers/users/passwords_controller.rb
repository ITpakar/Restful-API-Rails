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
        render action: 'success', full_name: @user.full_name
      else
        redirect_to :back
      end
    end

  end
end
