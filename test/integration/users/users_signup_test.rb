require 'test_helper'

# Checks that users are able to sign up, but only if they submit valid info
class UsersSignupTest < ActionDispatch::IntegrationTest
  INVALID_SIGNUPS = {
    no_username: { username: '', error_text: /[Uu]sername.*(blank|empty)/ },
    no_email: { email: '', error_text: /[Ee]mail.*(blank|empty)/ },
    no_password: { password: '', error_text: /[Pp]assword.*(blank|empty)/ },
    no_password_confirmation: { password_confirmation: '',
                                error_text: /[Pp]assword [Cc]onfirmation/ },
    too_short_password: { password: 'short', password_confirmation: 'short',
                          error_text: /[Ppassword]/ },
    improper_username: { username: 'Has A Space', error_text: /[Uu]sername/ }
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
    INVALID_SIGNUPS.each do |name, error_text:, **options|
      define_method "test_rejects_signup_with_#{name}_and_explains".to_sym do
        rejects_invalid_signup_and_explains(error_text, **options)
      end
    end
  end

  test 'rejects signup with email already taken' do
    sign_up
    rejects_invalid_signup_and_explains(/[Ee]mail/, email: User.last.email)
  end

  test 'rejects signup with username already taken' do
    sign_up
    rejects_invalid_signup_and_explains(/[Ue]sername/,
                                        username: User.last.username)
  end

  test 'rejects signup with invalid emails and explains' do
    %w[ex@ample exam.ple example ex@am...ple @am.ple ex@mp.
       ex@am+p.le].each do |invalid|
      rejects_invalid_signup_and_explains(/[Ee]mail/, email: invalid)
    end
  end

  private

  def rejects_invalid_signup_and_explains(error_text, **options)
    get new_user_path
    assert_no_difference('User.count') { sign_up(**options) }
    assert_errors_explained(error_text)
  end

  def sign_up(factory = :user, **options)
    post users_path, params: { user: attributes_for(factory, **options) }
  end
end
