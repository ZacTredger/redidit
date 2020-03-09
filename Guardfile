require 'active_support/core_ext/string'
# Defines the matching rules for Guard.
guard :minitest, spring: 'bin/rails test', all_on_start: false do
  # Important and basic things that need lots of tests when changed
  watch(%r{^test/(.*)/?(.*)_test\.rb$})
  watch('test/test_helper.rb') { 'test' }
  watch('test/factories.rb') { 'test' }
  watch('config/routes.rb') { interface_tests }
  watch(%r{app/views/layouts/*}) { interface_tests }
  watch(%r{^app/views/shared/.+$}) { integration_tests }
  watch('app/helpers/application_helper.rb') { integration_tests }

  # Resources whose tests are named conventionally
  watch(%r{^app/models/(.*?)\.rb$}) do |matches|
    "test/models/#{matches[1]}_test.rb"
  end
  watch(%r{^app/mailers/(.*?)\.rb$}) do |matches|
    "test/mailers/#{matches[1]}_test.rb"
  end
  watch(%r{^app/views/(.*)_mailer/.*$}) do |matches|
    "test/mailers/#{matches[1]}_mailer_test.rb"
  end
  watch(%r{^app/controllers/(.*?)_controller\.rb$}) do |(resource)|
    controller_test(resource)
    integration_tests(resource == 'users' ? 'users' : 'posts')
  end
  watch(%r{^app/views/([^/]*?)/.*\.html\.erb$}) do |matches|
    resource_tests(matches[1])
  end
  watch(%r{^app/helpers/(.*?)_helper\.rb$}) do |matches|
    integration_tests(matches[1])
  end

  # Features that don't map neatly to resources. eg feeds and sessions
  watch(%r{^app/.+/sessions.*\.rb$}) do
    'test/integration/users/users_login_test.rb'
  end
  watch(%r{^db/(post_maker|redidits)\.rb$}) do
    resource_tests('posts') + Dir['test/lib/*.rb']
  end
  watch(%r{^app/views/posts/_feed*}) { post_feed_tests }
  watch('app/models/post.rb') { post_feed_tests }
  watch('app/views/static_pages/home.html.erb') do
    'test/integration/homepage_test.rb'
  end
  watch(%r{^app/(models|controllers|views|helpers)/comment.*}) do
    integration_tests('posts')
  end
  watch(%r{^test/integration/(.*)/.*helper\.rb$}) do |matches|
    integration_tests(matches[1])
  end
  watch(%r{^app/(helpers/votable_helper|models/vote).rb}) { integration_tests }
end

# The integration tests corresponding to the given resource, or all integration
# tests if a resource isn't passed
def integration_tests(resource = '**')
  Dir["test/integration/#{resource}/*.rb"]
end

# All tests that hit the interface.
def interface_tests
  integration_tests << 'test/controllers'
end

# The controller tests corresponding to the given resource.
def controller_test(resource)
  "test/controllers/#{resource}_controller_test.rb"
end

# All tests for the given resource.
def resource_tests(resource)
  integration_tests(resource) << controller_test(resource)
end

# All tests of post feeds (on the homepage or user profiles)
def post_feed_tests
  %w[test/integration/users/users_profile_test.rb
     test/integration/homepage_test.rb]
end
