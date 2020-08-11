require 'test_helper'
require_relative 'posts_test_helper.rb'

class PostsEditTest < ActionDispatch::IntegrationTest
  include PostsTestHelpers

  test "can't edit post if not logged in" do
    get post_path(@post = create(:post))
    assert_select 'a[href=?]', edit_post_path(@post), count: 0
    get post_path(@post)
    get edit_post_path(@post)
    assert_redirected_to login_path
    send_update_to_post
    assert_redirect_with_bad_flash
  end

  test "can't edit post of another user" do
    get post_path(@post = create(:post))
    log_in
    assert_select 'a[href=?]', edit_post_path(@post), count: 0
    get edit_post_path(@post)
    assert_redirect_with_bad_flash
    send_update_to_post
    assert_redirect_with_bad_flash
  end

  test 'can edit post, which displays, updated' do
    log_in_and_view_own_post
    assert_select 'a[href=?]', edit_post_path(@post), text: /[Ee]dit/
    get edit_post_path(@post)
    assert_select 'form[action=?]', post_path(@post)
    post_params.each_value { |text| assert_select('input', value: text) }
    send_update_to_post
    assert_redirected_to post_path(@post.reload)
    follow_redirect!
    assert_post_contents_displayed
  end

  test "can't delete post if not logged-in" do
    get post_path(@post = create(:post))
    assert_select 'a[href=?][data-method=?][data-confirm]', post_path(@post),
                  'delete', count: 0
    assert_no_difference('Post.count') { delete post_path(@post) }
    assert_redirect_with_bad_flash
  end

  test "can't delete post of another user" do
    get post_path(@post = create(:post))
    log_in
    assert_select 'a[href=?]', post_path(@post), action: 'delete', count: 0
    assert_no_difference('Post.count') { delete post_path(@post) }
    assert_redirect_with_bad_flash
  end

  test 'can delete own post' do
    log_in_and_view_own_post
    assert_select 'a[href=?][data-method=?][data-confirm]', post_path(@post),
                  'delete', text: /[Dd]elete/
    assert_difference('Post.count', -1) { delete post_path(@post) }
    assert flash[:success]
  end

  private

  def log_in_and_view_own_post
    log_in as: (user = create(:user, :posts, posts_count: 1))
    get post_path(@post = user.posts.first)
  end

  # Arbitrarily amend the string values of the post_params hash
  def updated_post_params
    post_params.update(post_params) { |_k, v| v.is_a?(String) ? v + '_e' : nil }
  end

  def send_update_to_post
    patch post_path(@post), params: { post: updated_post_params }
  end
end
