class Users::Mailer < ActionMailer::Base
  default from: "Quotiful <no-reply@quotiful.com>"

  def reset_password_instructions(user_id)
    @user = User.find(user_id)
    @user.set_reset_password_token!

    mail(to: @user.email, subject: "Password reset on Quotiful")
  end
end
