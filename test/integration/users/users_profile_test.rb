require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  test 'static page features render correctly' do
    user = create(:user)
    post = create :post, user_id: user.id
    ([:down] * 1 + [:up] * 2)
      .each { |direction| create(:vote, direction, votable: post) }
    comment = create :comment, user: user
    ([:down] * 4 + [:up] * 8)
      .each { |direction| create(:vote, direction, votable: comment) }
    username_regex = /#{user.username}/
    get user_path(user)
    assert_select 'title', count: 1, text: username_regex
    assert_select '.bio', text: username_regex do |bio|
      assert_select bio, '.karma p', text: /7/
    end
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
    assert_select '.post-row', count: 5 do |posts_info|
      posts_info.each do |post_info|
        assert_select post_info, 'a.post-page', count: 1 do |(post_link)|
          # Remove each matched post from the list so they can't match with
          # multiple elements
          assert post = title_to_post.delete(post_link.text)
          assert_equal post_path(post), post_link['href']
          # Check user-links are displayed
          assert_select post_info, 'a.external-link' do |(external_link)|
            assert_equal 'reddit.com', external_link.text
            assert_equal post.link, external_link['href']
          end
          # Check post metadata
          assert_select post_info, 'a[href=?]', user_path(o_p = post.user),
                        text: /#{o_p.username}/
          # Check vote controls (not upvoted by OP because they're factory-made)
          %i[up down].each do |direction|
            assert_select post_info, "##{direction}vote-post-#{post.id}"
          end
          assert_select post_info, '.karma', text: '1'
        end
      end
    end
  end

  test 'feed paginates correctly' do
    user = create(:user, :posts, posts_count: 21)
    get user_path(user)
    assert_select '.post-row', count: 20
  end
end
