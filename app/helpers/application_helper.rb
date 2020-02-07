module ApplicationHelper
  # Resolves current user (or guest) by checking session then permanent cookies
  class TheUser
    include ApplicationHelper
    class << self
      def resolve_from_session(user_id)
        resolve_from_id(user_id) if user_id
      end

      def resolve_from_cookies(cookies)
        resolve_from_id(cookies.signed[:user_id])
          .authenticate_from_memory(cookies[:remember_token])
      end

      def resolve_from_id(user_id)
        User.find_by(id: user_id)
      end
    end
  end

  # Adds user's ID to session
  def log_in(user = @user)
    session[:user_id] = user.id
  end

  # Removes user's ID from session
  def log_out
    session.delete(:user_id)
  end

  # Returns the current user and sets the instance corresponding variable
  def current_user
    @current_user ||=
      if (user_id = session[:user_id])
        TheUser.resolve_from_session(user_id)
      else
        log_in_possible_user(TheUser.resolve_from_cookies(cookies))
      end
  end

  # Appends ' | Redidit' to title, or returns homepage title
  def full_title(title)
    site_name = 'Redidit'
    return site_name if title.blank?

    title + ' | ' + site_name
  end

  # Stores in the session the path currently requested for re-redirection later
  def store_location(location = request.original_fullpath)
    session[:forwarding_path] ||= location if request.get?
  end

  # Redirects to path stored in the session, or else to the root
  def redirect_back(default: root_path)
    redirect_to(session[:forwarding_path] || default)
    session.delete(:forwarding_path)
  end

  private

  # Logs in user & refreshes cookies (unless user is a guest); returns user
  def log_in_possible_user(user)
    if user.exists?
      log_in(user)
      remember(user)
    end
    user
  end

  # Remove remember_token so user will have to log on
  def forget(user = @user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
end
