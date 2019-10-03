# Helper methods with access to view helpers
module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
    redirect_to user_path(user)
  end

  def reject_log_in
    flash.now[:danger] = 'Invalid email/password combination'
    render :new
  end

  def logged_in?
    current_user.exists?
  end

  # Returns the current user; by checking session
  def current_user
    (user_id = session[:user_id]) ? User.find(user_id) : GuestUser
  end
end

# Active nothing for User object
class GuestUser
  def self.exists?
    false
  end
end
