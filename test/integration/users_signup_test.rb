require 'test_helper'

# Checks that users are able to sign up, but only if they submit valid infor
class UsersSignupTest < ActionDispatch::IntegrationTest
  test 'Rejects invalid user info and re-renders signup with errors' do
    get new_user_path
    assert_select 'form[action="/signup"]'
    assert_select '#error-explanation', false
    assert_no_difference 'User.count' do
      post users_path, params: { user: { username: 'Username',
                                         email: 'ex@mple.com',
                                         password: 'password',
                                         password_confirmation: '' } }
    end
    assert_select 'form[action="/signup"]'
    assert_select '#error-explanation'
    assert_select '.alert'
  end

  test "Accepts valid user info and redirects to new user's page" do
    get new_user_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { username: 'Username',
                                         email: 'ex@mple.com',
                                         password: 'password',
                                         password_confirmation: 'password' } }
    end
    assert_redirected_to User.last
    follow_redirect!
    assert_select 'img.gravatar'
  end
end
