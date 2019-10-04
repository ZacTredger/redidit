# Helper methods with access to view helpers
module SessionsHelper
  def accept_log_in(remember_me)
    log_in
    remember_me == '1' ? remember : forget
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
    TheUser.resolve(id_from_session: session[:user_id], cookies: cookies)
  end

  private

  def log_in(user = @user)
    session[:user_id] = user.id
    redirect_to user_path(user)
  end

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

  # Resolves current user (or guest) from cookies, session or user_id
  class TheUser
    class << self
      def resolve(id_from_session:, cookies:)
        return resolve_from_id(id_from_session) if id_from_session

        resolve_from_id((permanent_cookies = cookies.permanent)[:user_id])
          .authenticate_from_memory(permanent_cookies[:remember_token])
      end

      def resolve_from_id(user_id)
        User.find_by(id: user_id)
      end
    end
  end
end
