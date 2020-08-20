ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require_relative '../app/helpers/application_helper'
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

module ActiveSupport
  class TestCase
    include ApplicationHelper
    include FactoryBot::Syntax::Methods
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    private

    # Log in. If no user is passed, one is created from the user factory.
    # Optionally pass email or password keyword args to incorrectly sign in.
    def log_in(as: create(:user), email: nil, password: 'password',
               remember_me: '0')
      post sessions_path, params: { user: { email: email || as.email,
                                            password: password,
                                            remember_me: remember_me } }
      as
    end

    # Tests whether the controller redirected with a flash other than :success
    def assert_redirect_with_bad_flash(location: nil)
      location ? assert_redirected_to(location) : assert_response(:redirect)
      assert flash && !flash[:success]
    end

    # Pass any error messages; confirms those messages are displayed & formatted
    def assert_errors_explained(*error_texts)
      assert_select '#error-explanation', count: 1 do |errors|
        error_texts.each do |error_text|
          assert_select errors, 'li', count: 1, text: error_text
        end
      end
    end

    # Confirms that the header contains login & signup but not sign-out links
    def assert_logged_out_header
      assert_select 'a[href=?]', logout_path, false
      assert_select 'form[action=?]', login_path, method: :get
      assert_select 'form[action=?]', signup_path, method: :get
    end

    # Confirms that the header contains sign-out but not login or signup links
    def assert_logged_in_header
      assert_select 'a[data-method=delete]', count: 1 do |(logout_link)|
        assert_match(/#{logout_path}/, logout_link[:href])
      end
      assert_select 'form[action=?]', login_path, false
      assert_select 'form[action=?]', signup_path, false
    end
  end
end
