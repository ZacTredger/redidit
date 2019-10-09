require 'test_helper'

class PostNewTest < ActionDispatch::IntegrationTest
  setup do
    @post_params = { title: 'The title', link: 'link.com', body: 'The body' }
  end

  test "can't create a post when not logged in" do
    get new_post_path
    assert_redirected_to login_path
  end

  test 'invalid post return to form with errors highlighted' do
    log_in_as(@user)
    get new_post_path
    @post_params.update(@post_params) { '' }
    assert_no_difference('Post.count') { make_post }
    assert_select 'div#error-explanation', count: 1 do |errors|
      assert_select errors, 'li', minimum: 2
    end
  end

  test 'can create post, which displays' do
    post_successfully(true)
  end

  test "can't edit post if not logged in" do
    post_successfully
    delete logout_path
    get edit_post_path(@post)
    assert_redirected_to login_path
  end

  test "can't edit post of another user" do
    post_successfully
    log_in_as @other_user
    get edit_post_path(@post)
    assert_response :redirect
    assert flash && flash[:danger]
  end

  test 'can edit post, which displays, updated' do
    post_successfully
    get edit_post_path(@post)
    assert_select 'form[action=?]', post_path(@post)
    @post_params.each_value { |text| assert_select('input', value: text) }
    @post_params.update(@post_params) { |_k, v| 'e_' + v }
    patch post_path(@post), params: { post: @post_params }
    assert_redirected_to post_path(@post)
    follow_redirect!
    assert_post_contents_displayed
  end

  test "can't delete post if not logged-in" do
    post_successfully
    delete logout_path
    assert_no_difference('Post.count') { delete post_path(@post) }
    assert_redirected_to login_path
  end

  test "can't delete post of another user" do
    post_successfully
    log_in_as @other_user
    assert_no_difference('Post.count') { delete post_path(@post) }
    assert_response :redirect
    assert flash && flash[:danger]
  end

  test 'can delete post' do
    post_successfully
    assert_difference('Post.count', -1) { delete post_path(@post) }
    assert flash[:success]
  end

  private

  def post_successfully(assert = false)
    log_in_as(@user)
    get new_post_path
    assert_select 'form[action=?]', posts_path if assert
    assert ? assert_difference('Post.count', 1) { make_post } : make_post
    @post = Post.last
    return unless assert

    assert_redirected_to post_path(@post)
    follow_redirect!
    assert_post_contents_displayed
  end

  def make_post
    post posts_path, params: { post: @post_params }
  end

  def assert_post_contents_displayed
    if (link = @post_params[:link])
      assert_select('a[href=?]', link, text: @post_params[:title])
    else
      assert_select('body', text: /#{@post_params[:title]}/)
    end
    return unless (body = @post_params[:body])

    assert_select('body', text: /#{body}/)
  end
end
