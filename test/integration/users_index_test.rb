require 'test_helper'

# Test the user index page appears appropriately for users' authorization levels
class UsersIndexTest < ActionDispatch::IntegrationTest
  test 'Shows info about each user and links to their page' do
    get users_path
    assert_select 'li.user', minimum: 5 do |user_summaries|
      user_summaries.each do |user_summary|
        assert_select user_summary, 'img.gravatar', count: 1
        assert_select user_summary, 'a.user-link', count: 1 do |user_links|
          user = User.find_by(username: user_links.first.text)
          assert_select user_links, 'a[href=?]', user_path(user)
          assert_select user_summary, 'a[href=?]', edit_user_path(user)
          assert_select user_summary,
                        'a[href=?][data-method=?][data-confirm]',
                        user_path(user), 'delete'
        end
      end
    end
  end
end
