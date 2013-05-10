class Api::V1::UsersController < Api::BaseController
  def email_check
    user_exists = User.exists?(email: params[:user][:email])

    json = Jbuilder.encode do |json|
      json.data do |data|
        data.email params[:user][:email]
        data.user_exists? user_exists
      end
      json.status 200
    end
    
    render json: json, status: 200
  end
end
