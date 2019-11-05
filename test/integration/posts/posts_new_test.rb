require 'test_helper'
require_relative 'posts_test.rb'

class PostsNewTest < ActionDispatch::IntegrationTest
  include PostsTestHelpers
  test "can't create a post when not logged in" do
    get new_post_path
    assert_redirected_to login_path
  end

  test 'invalid post return to form with errors highlighted' do
    log_in_as create(:user)
    get new_post_path
    post_params.update(post_params) { '' }
    assert_no_difference('Post.count') { make_post }
    assert_select 'div#error-explanation', count: 1 do |errors|
      assert_select errors, 'li', minimum: 2
    end
  end

  test 'can create post, which displays' do
    log_in_as create(:user)
    get new_post_path
    assert_response :success
    assert_select 'form[action=?]', posts_path
    assert_difference('Post.count', 1) { make_post }
    assert_redirected_to post_path(@post = Post.last)
    follow_redirect!
    assert_post_contents_displayed
  end
end
