require 'test_helper'

# Test the user index page appears appropriately for users' authorization levels
class UsersIndexTest < ActionDispatch::IntegrationTest
  test "shows users' info & links to their page; shows edit/destroy for self" do
    @current_user = log_in
    create(:user)
    get users_path
    assert_select 'li.user', count: 2 do |user_summaries|
      assert_displays_current_and_other_users(user_summaries)
    end
  end

  test 'index paginates correctly' do
    log_in
    21.times { create(:user) }
    get users_path
    assert_select 'li.user', count: 20
  end

  private

  def assert_displays_current_and_other_users(user_summaries)
    user_summaries.each_with_object([false, false]) do |summary, works|
      assert_select summary, 'img.gravatar', count: 1
      assert_select summary, 'a.user-link', count: 1 do |user_links|
        displays_user_links(user_links, summary, works)
      end
    end
  end

  # The user's own summary should display with links to edit and delete it
  def displays_user_links(user_links, summary, works)
    a_user = User.find_by(username: user_links.first.text)
    assert_select user_links, 'a[href=?]', user_path(a_user)
    count = a_user == @current_user ? 1 : 0
    works[count] = true
    assert_select summary, 'a[href=?]', edit_user_path(a_user), count: count
    assert_select summary, 'a[href=?][data-method=?][data-confirm]',
                  user_path(a_user), 'delete', count: count
  end
end
