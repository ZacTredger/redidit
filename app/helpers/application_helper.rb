module ApplicationHelper
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

  # Returns the current user; by checking session
  def current_user
    TheUser.resolve(id_from_session: session[:user_id], cookies: cookies)
  end

  def full_title(title)
    site_name = 'Redidit'
    return site_name if title.blank?

    title + ' | ' + site_name
  end

  def store_location
    session[:forwarding_path] = request. original_fullpath if request.get?
  end

  def redirect_back(default: root_path)
    redirect_to(session[:forwarding_path] || default)
    session.delete(:forwarding_path)
  end
end
