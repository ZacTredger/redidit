ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require_relative '../app/helpers/application_helper.rb'
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

module ActiveSupport
  class TestCase
    include ApplicationHelper
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests, alphabetically.
    fixtures :all

    setup do
      @user = User.first
      @other_user = User.last
    end

    def log_in_as(email: @user.email, password: 'password', remember_me: '0')
      post sessions_path, params: { user: { email: email,
                                            password: password,
                                            remember_me: remember_me } }
    end
  end
end
