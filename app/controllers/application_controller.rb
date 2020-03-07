class ApplicationController < ActionController::Base
  include ApplicationHelper
  include SessionHelper
  protect_from_forgery with: :exception
  rescue_from ActionController::InvalidAuthenticityToken do
    forget current_user
    log_out
  end

  # Generic before-filters
  # Redirects non-logged-in users to login page, but puts current path in cookie
  def reject_unless_user_logged_in
    return if user_is_logged_in?

    store_location
    flash[:danger] = 'Please log in'
    redirect_to login_path
  end

  # Allows access only if the current user and the user whose page it is match
  def correct_user(id = params[:id])
    return if current_user == TheUser.resolve_from_id(id)

    flash[:danger] = 'You were not authorized to access that page'
    redirect_to root_path
  end
end
