class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Generic berfore-filters
  # Redirects non-logged-in users to login page, but puts current path in cookie
  def logged_in_user
    return if current_user.exists?

    store_location
    flash[:danger] = 'Please log in'
    redirect_to login_path
  end
end
