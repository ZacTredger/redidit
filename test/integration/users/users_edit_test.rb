require 'test_helper'

# Test users can update their usernames, emails and passwords
class UsersEditTest < ActionDispatch::IntegrationTest
  test 'edit without login redirects then directs back' do
    get edit_user_path(@user = create(:user))
    assert_redirected_to login_path
    follow_redirect!
    assert flash && flash[:danger]
    log_in_as @user
    assert_redirected_to edit_user_path(current_user)
  end

  test 'edit of different user not permitted' do
    log_in_as create(:user)
    get edit_user_path(create(:user))
    assert_redirect_with_bad_flash(location: root_path)
  end

  test 'update without login not permitted; redirects to login' do
    update_with_valid_details create(:user)
    assert_redirect_with_bad_flash(location: login_path)
  end

  test 'update of different user not permitted' do
    log_in_as create(:user)
    update_with_valid_details create(:user)
    assert_redirect_with_bad_flash(location: root_path)
  end

  test 'deletion without login not permitted; redirects to login' do
    @user = create(:user)
    assert_no_difference('User.count') { delete user_path(@user) }
    assert_redirect_with_bad_flash(location: login_path)
  end

  test 'deletion of different user not permitted' do
    log_in_as create(:user)
    @other_user = create(:user)
    assert_no_difference('User.count') { delete user_path(@other_user) }
    assert_redirect_with_bad_flash(location: root_path)
  end

  test 'edit form is populated with current details' do
    log_in_as create(:user)
    get edit_user_path(current_user)
    assert_select 'form[action=?]', user_path(current_user)
    assert_select 'input#user_username', value: current_user.username
    assert_select 'input#user_email', value: current_user.username
    assert_select 'div.edit-gravatar', count: 1 do |grav_edit|
      assert_select grav_edit, 'img.gravatar', count: 1
      assert_select grav_edit, 'a' do |links|
        assert_equal current_user.edit_gravatar_url,
                     links.first.attribute('href').value
      end
    end
  end

  test 'update of self with invalid details rejected' do
    log_in_as create(:user)
    patch user_path(current_user),
          params: { user: { username: '', email: '', password: '',
                            password_confirmation: '' } }
    assert_select 'div#error-explanation', count: 1 do |errors|
      assert_select errors, 'li', minimum: 2
    end
    assert_select 'form[action=?]', user_path(current_user)
    assert_equal current_user, current_user.reload
  end

  test 'update with valid details updates user attributes & redirects' do
    log_in_as create(:user)
    update_with_valid_details
    assert_redirected_to user_path(current_user)
    follow_redirect!
    assert flash && flash[:success]
    assert_equal current_user.reload.username, @new_name
    assert_equal current_user.reload.email, @new_email
  end

  test 'deletion request confirms certainty, then destroys user' do
    log_in_as create(:user)
    get edit_user_path(current_user)
    assert_select 'form[action=?][data-confirm]',
                  user_path(current_user) do |form|
      assert_select form, 'input[name=?][value=?]', '_method', 'delete'
    end
    assert_difference 'User.count', -1 do
      delete user_path(current_user)
    end
    assert_redirected_to root_path
    follow_redirect!
    assert flash && flash[:success]
  end

  private

  def update_with_valid_details(updating_user = current_user)
    @new_name = '1' + updating_user.username
    @new_email = '1' + updating_user.email
    patch user_path(updating_user), params: { user: { username: @new_name,
                                                      email: @new_email } }
  end
end
