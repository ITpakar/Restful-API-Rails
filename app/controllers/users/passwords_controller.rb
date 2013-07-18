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
        render template: 'success'
      else
        render template: 'failed'
      end
    end

  end
end
