# Controls actions on the session resource
class SessionsController < ApplicationController
  include SessionsHelper
  include ApplicationHelper
  def new; end

  def create
    user_params = params[:user] || {}
    if (@user = User.find_by(email: user_params[:email].downcase))
       .authenticate(user_params[:password])
      accept_log_in(user_params[:remember_me])
    else
      @user = User.new email: user_params[:email]
      reject_log_in
    end
  end

  def destroy
    session.delete(:user_id) if logged_in?
    redirect_to root_path
  end
end
