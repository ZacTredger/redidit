require 'test_helper'

# Test the user index page appears appropriately for users' authorization levels
class UsersIndexTest < ActionDispatch::IntegrationTest
  test "shows users' info & links to their page; shows edit/destroy for self" do
    log_in_as
    21.times { create(:user) }
    get users_path
    assert_select 'li.user', count: 20 do |user_summaries|
      assert displays_current_and_other_users(user_summaries).all?,
        'The logged-in user was not displayed. (Did you added a scope?)'
    end
  end

  private

  def displays_current_and_other_users(user_summaries)
    user_summaries.each_with_object([false, false]) do |summary, works|
      break works if works.all?

      assert_select summary, 'img.gravatar', count: 1
      assert_select summary, 'a.user-link', count: 1 do |user_links|
        user = User.find_by(username: user_links.first.text)
        assert_select user_links, 'a[href=?]', user_path(user)
        count = user == @user ? 1 : 0
        works[count] = true
        assert_select summary,
                      'a[href=?]', edit_user_path(user), count: count
        assert_select summary,
                      'a[href=?][data-method=?][data-confirm]',
                      user_path(user), 'delete', count: count
      end
    end
  end
end
