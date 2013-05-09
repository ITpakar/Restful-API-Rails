class Api::V1::UsersController < Api::BaseController
  def email_check
    user_exists = User.exists?(email: params[:user][:email])

    json = Jbuilder.encode do |json|
      json.data do |data|
        json.email params[:user][:email]
        json.new_record? user_exists
      end
    end
    render json: json
  end
end
