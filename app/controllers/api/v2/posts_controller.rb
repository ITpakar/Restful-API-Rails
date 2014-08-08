class Api::V2::PostsController < Api::V1::PostsController
  def editors_picks
    @posts = Post.editors_picked.page(params[:page]).per(params[:count] || 10)

    json = Response::Collection.new('post', @posts, {current_user_id: current_user.id, page: params[:page], api_version: @api_version}).to_json

    render json: json, status: 200
  end

  def popular
    @posts = Post.popular.page(params[:page]).per(params[:count] || 10)

    json = Response::Collection.new('post', @posts, {current_user_id: current_user.id, page: params[:page], api_version: @api_version}).to_json

    render json: json, status: 200
  end
end
