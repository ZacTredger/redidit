require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  test 'static page features render correctly' do
    user = create(:user)
    username_regex = /#{user.username}/
    get user_path(user)
    assert_select 'title', count: 1, text: username_regex
    assert_select 'aside.user-info', text: username_regex
  end

  test 'each post in the feed belongs to the user' do
    # Create posts by other users to ensure they're not on the user's page
    4.times { create(:post) }
    user = create(:user, :posts, posts_count: 5)
    # Map each post title to the post object
    title_to_post = user.posts.each_with_object({}) do |post, hsh|
      hsh[post.title] = post
    end
    get user_path(user)
    # Catch each list item containing preview info about a post
    assert_select 'li.post-info', count: 5 do |posts_info|
      posts_info.each do |post_info|
        assert_select post_info, 'a.post-link', count: 1 do |(post_link)|
          # Remove each matched post from the list so they can't match with
          # multiple elements
          assert post = title_to_post.delete(post_link.text)
          assert_equal post_path(post), post_link['href']
          # Check post metadata
          assert_select post_info, 'a[href=?]', user_path(o_p = post.user),
                        text: /#{o_p.username}/
        end
      end
    end
  end

  test 'feed paginates correctly' do
    user = create(:user, :posts, posts_count: 21)
    get user_path(user)
    assert_select 'li.post-info', count: 20
  end
end
