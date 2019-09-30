# Controls actions on the user resource
class UsersController < ApplicationController
  helper UsersHelper
  def show
    @user = User.find(params[:id])
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

    redirect_to @user
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    return (render :edit) unless @user&.update(user_params)

    redirect_to @user
  end

  def destroy; end

  private

  def user_params
    params.require(:user)
          .permit(:username, :email, :password, :password_confirmation)
  end
end
