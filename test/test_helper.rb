ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require_relative '../app/helpers/application_helper.rb'
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

    def log_in_as(user = create(:user), email: nil, password: 'password',
                  remember_me: '0')
      post sessions_path, params: { user: { email: email || user.email,
                                            password: password,
                                            remember_me: remember_me } }
    end

    def assert_redirect_with_bad_flash(location: nil)
      location ? assert_redirected_to(location) : assert_response(:redirect)
      assert flash && !flash[:success]
    end

    def assert_errors_explained(*error_texts)
      assert_select '#error-explanation', count: 1 do |errors|
        error_texts.each do |error_text|
          assert_select errors, 'li', count: 1, text: error_text
        end
      end
    end
  end
end
