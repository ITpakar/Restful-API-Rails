class Posts::Mailer < ActionMailer::Base
  default from: "no-reply@quotiful.com"

  def deleted_post(user_id)
    @user = User.find(user_id)
    mail(to: @user.email, subject: "Your Quotiful has been removed")
  end
end
