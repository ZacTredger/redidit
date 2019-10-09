require 'test_helper'

# Test the user index page appears appropriately for users' authorization levels
class UsersIndexTest < ActionDispatch::IntegrationTest
  test "shows users' info & links to their page; shows edit/destroy for self" do
    log_in_as
    get users_path
    assert_select 'li.user', minimum: 5 do |user_summaries|
      user_summaries.each do |user_summary|
        assert_select user_summary, 'img.gravatar', count: 1
        assert_select user_summary, 'a.user-link', count: 1 do |user_links|
          user = User.find_by(username: user_links.first.text)
          assert_select user_links, 'a[href=?]', user_path(user)
          count = user == @user ? 1 : 0
          assert_select user_summary,
                        'a[href=?]', edit_user_path(user), count: count
          assert_select user_summary,
                        'a[href=?][data-method=?][data-confirm]',
                        user_path(user), 'delete', count: count
        end
      end
    end
  end
end
