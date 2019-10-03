# Controls actions on the session resource
class SessionsController < ApplicationController
  include SessionsHelper
  def new; end

  def create
    if (@user = User.find_by(email: params.dig(:user, :email)))
         &.authenticate(params.dig(:user, :password))
      log_in @user
    else
      reject_log_in
    end
  end

  def destroy
    session.delete(:user_id) if logged_in?
    redirect_to root_path
  end
end
