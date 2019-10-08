# Helper methods with access to view helpers
module SessionsHelper
  include ApplicationHelper
  def accept_log_in(remember_me)
    log_in
    remember_me == '1' ? remember : forget
    redirect_back
  end

  def reject_log_in
    flash.now[:danger] = 'Invalid email/password combination'
    render :new
  end

  def logged_in?
    current_user.exists?
  end

  private

  # Generate random token; store it in permanent cookie, and its digest in DB
  def remember(user = @user)
    user.remember
    permanent_cookies = cookies.permanent
    permanent_cookies.signed[:user_id] = user.id
    permanent_cookies[:remember_token] = user.remember_token
  end

  # Remove remember_token so user will have to log on
  def forget(user = @user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
end
