require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  test 'login attempt with incorrect password is rejected with errors' do
    assert_invalid_login_rejected(password: '')
  end

  test 'login attempt with invalid email is rejected with errors' do
    assert_invalid_login_rejected(email: 'invalid_email')
  end

  test "accepts valid login & redirects user to user's page, then logs out" do
    assert_log_in
    assert_redirected_to root_path
    follow_redirect!
    assert_logged_in_header
    refute cookies[:remember_token]
    delete logout_path
    assert_redirected_to root_path
    follow_redirect!
    assert_logged_out_header
  end

  test 'login with remember-me request saves cookie' do
    assert_log_in(remember_me: '1')
    assert cookies[:user_id]
    assert cookies[:remember_token]
  end

  test 'login without remember-me request does not save cookie' do
    assert_log_in(remember_me: '0')
    refute cookies[:user_id]
    refute cookies[:remember_token]
  end

  test 'forces login on privileged page then redirects back' do
    get edit_user_path(@user = create(:user))
    assert_redirected_to login_path
    follow_redirect!
    log_in_as @user
    assert_redirected_to edit_user_path(@user)
  end

  test "login to different account doesn't redirect back to other's page" do
    get edit_user_path(@other_user = create(:user))
    assert_redirected_to login_path
    follow_redirect!
    log_in_as create(:user)
    assert_redirect_with_bad_flash
  end

  test 'remembered-me users remembered & logged in after session expiry' do
    log_in_as(remember_me: '1')
    old_remember_token = cookies[:remember_token]
    session.delete(:user_id)
    get root_path
    assert_logged_in_header
    assert session[:user_id]
    # Test that the remember digest & token have been refreshed
    refute_equal old_remember_token, current_user.remember_token
  end

  private

  def assert_invalid_login_rejected(**keyword_args)
    assert_log_in(**keyword_args)
    assert_on_login_page
    assert flash[:danger]
  end

  def assert_log_in(**keyword_args)
    get new_session_path
    assert_on_login_page
    log_in_as(**keyword_args)
  end

  def assert_on_login_page
    assert_select 'form[action=?]', sessions_path, method: :post do |form|
      assert_select form, 'a[href=?]', signup_path
    end
  end
end
