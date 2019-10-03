require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  setup do
    @user = users.first
  end

  test 'login attempt with incorrect password is rejected with errors' do
    assert_invalid_login_rejected(password: '')
  end

  test 'login attempt with invalid email is rejected with errors' do
    assert_invalid_login_rejected(email: 'invalid_email')
  end

  test "accepts valid login & redirects user to user's page, then logs out" do
    assert_log_in
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', login_path, false
    assert_select 'a[href=?]', signup_path, false
    delete logout_path
    assert_redirected_to root_path
    follow_redirect!
    assert_select 'a[href=?]', logout_path, false
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', signup_path
  end

  private

  def assert_invalid_login_rejected(**keyword_args)
    assert_log_in(**keyword_args)
    assert_on_login_page
    assert flash[:danger]
  end

  def assert_log_in(email: @user.email, password: 'password')
    get new_session_path
    assert_on_login_page
    post sessions_path, params: { user: { email: email,
                                          password: password } }
  end

  def assert_on_login_page
    assert_select 'form[action=?]', sessions_path
    assert_select 'a[href=?]', logout_path, false
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', signup_path, count: 2
  end
end
