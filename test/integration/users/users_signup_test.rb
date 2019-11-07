require 'test_helper'

# Checks that users are able to sign up, but only if they submit valid info
class UsersSignupTest < ActionDispatch::IntegrationTest
  INVALID_SIGNUPS = {
    no_username: { factory: :user_without_username,
                    error_text: /[Uu]sername.*(blank|empty)/ },
    no_email: { factory: :user_without_email,
                 error_text: /[Ee]mail.*(blank|empty)/ },
    no_password: { factory: :user_without_password,
                    error_text: /[Pp]assword.*(blank|empty)/ },
    no_password_confirmation: { factory: :user_without_password_confirmation,
                                 error_text: /[Pp]assword [Cc]onfirmation/ },
    too_short_password: { factory: :user_with_short_password,
                           error_text: /[Ppassword]/ },
    improper_username: { error_text: /[Uu]sername/, username: 'Has A Space' },
  }
  
  test "Accepts valid user info and redirects to new user's page" do
    get new_user_path
    assert_select 'form[action="/signup"]'
    assert_select '#error-explanation', false
    assert_difference('User.count', 1) { sign_up }
    assert_redirected_to User.last
    follow_redirect!
    assert flash && flash[:success]
    assert_select 'img.gravatar'
  end

  SETUP = begin
    INVALID_SIGNUPS.each do |name, factory: :user, error_text:, **options|
      define_method "test_rejects_signup_with_#{name}_and_explains".to_sym do
        rejects_invalid_signup_and_explains(factory, error_text, **options)
      end
    end
  end

  test 'rejects signup with email already taken' do
    sign_up
    rejects_invalid_signup_and_explains(:user, /[Ee]mail/,
                                        email: User.last.email)
  end

  test 'rejects signup with invalid emails and explains' do
    %w[ex@ample exam.ple example ex@am...ple @am.ple ex@mp.
       ex@am+p.le].each do |invalid|
      rejects_invalid_signup_and_explains(:user, /[Ee]mail/, email: invalid)
    end
  end

  private

  def rejects_invalid_signup_and_explains(factory, error_text, **options)
    get new_user_path
    assert_no_difference('User.count') { sign_up(factory, **options) }
    assert_errors_explained(error_text)
  end

  def sign_up(factory = :user, **options)
    post users_path, params: { user: attributes_for(factory, **options) }
  end
end
