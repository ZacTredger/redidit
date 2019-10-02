require 'test_helper'

# Test users can update their usernames, emails and passwords
class UsersEditTest < ActionDispatch::IntegrationTest
  setup do
    @user = users.first
  end

  test 'Edit with invalid details rejected' do
    get edit_user_path(@user)
    assert_select 'form[action=?]', user_path(@user)
    assert_select 'input#user_username', value: @user.username
    assert_select 'input#user_email', value: @user.username
    assert_select 'div.edit-gravatar', count: 1 do |grav_edit|
      assert_select grav_edit, 'img.gravatar', count: 1
      assert_select grav_edit, 'a' do |links|
        assert_equal @user.edit_gravatar_url,
                     links.first.attribute('href').value
      end
    end
    patch user_path(@user), params: { user: { username: '',
                                              email: '',
                                              password: '',
                                              password_confirmation: '' } }
    assert_select 'div#error-explanation', count: 1 do |errors|
      assert_select errors, 'li', minimum: 2
    end
    assert_select 'form[action=?]', user_path(@user)
    assert_equal @user.reload, @user
  end

  test 'Edit with valid details updates user attributes & redirects' do
    new_name = '1' + @user.username
    new_email = '1' + @user.email
    patch user_path(@user), params: { user: { username: new_name,
                                              email: new_email } }
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert flash && flash[:success]
    assert_equal @user.reload.username, new_name
    assert_equal @user.reload.email, new_email
  end
end
