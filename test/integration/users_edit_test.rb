require 'test_helper'

# Test users can update their usernames, emails and passwords
class UsersEditTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.first
    @other_user = User.last
  end

  test 'edit without login redirects then directs back' do
    get edit_user_path(@user)
    assert_redirected_to login_path
    follow_redirect!
    assert flash && flash[:danger]
    log_in
    assert_redirected_to edit_user_path(@user)
  end

  test 'edit of different user not permitted' do
    log_in(email: @other_user.email)
    get edit_user_path(@user)
    assert_redirected_to root_path
    assert flash && flash[:danger]
  end

  test 'update without login not permitted; redirects to login' do
    update_with_valid_details
    assert_redirected_to login_path
    assert flash && flash[:danger]
  end

  test 'update of different user not permitted' do
    log_in(email: @other_user.email)
    update_with_valid_details
    assert_redirected_to root_path
    assert flash && flash[:danger]
  end

  test 'deletion without login not permitted; redirects to login' do
    assert_no_difference('User.count') { delete user_path(@user) }
    assert_redirected_to login_path
    assert flash && flash[:danger]
  end

  test 'deletion of different user not permitted' do
    log_in(email: @other_user.email)
    assert_no_difference('User.count') { delete user_path(@user) }
    assert_redirected_to root_path
    assert flash && flash[:danger]
  end

  test 'edit form is populated with current details' do
    log_in
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
  end

  test 'update of self with invalid details rejected' do
    log_in
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

  test 'update with valid details updates user attributes & redirects' do
    log_in
    update_with_valid_details
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert flash && flash[:success]
    assert_equal @user.reload.username, @new_name
    assert_equal @user.reload.email, @new_email
  end

  test 'deletion request confirms certainty, then destroys user' do
    log_in
    get edit_user_path(@user)
    assert_select 'form[action=?][data-confirm]', user_path(@user) do |form|
      assert_select form, 'input[name=?][value=?]', '_method', 'delete'
    end
    assert_difference 'User.count', -1 do
      delete user_path(@user)
    end
    assert_redirected_to root_path
    follow_redirect!
    assert flash && flash[:success]
  end

  private

  def update_with_valid_details(user = @user)
    @new_name = '1' + user.username
    @new_email = '1' + user.email
    patch user_path(user), params: { user: { username: @new_name,
                                             email: @new_email } }
  end
end
