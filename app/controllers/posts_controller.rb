class PostsController < ApplicationController
  include ApplicationHelper
  before_action :logged_in_user, except: %i[index show]
  def index; end

  def show
    return if (@post = Post.find_by(id: params[:id]))

    flash[:error] = 'Post not found'
    redirect_to root_path
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params.merge(user_id: current_user.id))
    return (render :new) unless @post.save

    redirect_to @post
  end

  def edit; end

  def update; end

  def destroy; end

  private

  def post_params
    params.require(:post).permit(:title, :link, :body)
  end
end
