# Controls actions on the user resource
class UsersController < ApplicationController
  include UsersHelper
  include ApplicationHelper
  before_action :logged_in_user, only: %i[edit update destroy]
  before_action :correct_user, only: %i[edit update destroy]
  def show
    @user = User.find(params[:id])
    @posts = @user.posts.send(params[:order] || :recent).page(params[:page])
  end

  def index
    @users = User.page(params[:page]).order('created_at')
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    return (render :new) unless @user.save

    flash[:success] = 'Account created'
    redirect_to @user
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    return (render :edit) unless @user&.update(user_params)

    flash[:success] = 'Profile updated'
    redirect_to @user
  end

  def destroy
    TheUser.resolve_from_id(params[:id]).destroy
    flash[:success] = 'Account deleted'
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user)
          .permit(:username, :email, :password, :password_confirmation)
  end
end
