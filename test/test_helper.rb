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

    setup do
      @user = create :user
    end

    def other_user
      @other_user ||= create :user
    end

    def log_in_as(user = @user, email: user.email, password: 'password',
                  remember_me: '0')
      post sessions_path, params: { user: { email: email,
                                            password: password,
                                            remember_me: remember_me } }
    end
  end
end
