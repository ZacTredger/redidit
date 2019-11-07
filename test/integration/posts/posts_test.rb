require 'test_helper'

module PostsTestHelpers
  def make_post
    post posts_path, params: { post: post_params }
  end

  def post_params
    @post_params ||= attributes_for(:post)
  end

  # Expects @post to have a 1 line body, & to have been created via the new post
  # form in the last request
  def assert_post_contents_displayed
    post_params[:link] ? assert_linked_title : assert_title
    assert_select('p', text: post_params[:body])
    assert_select('a[href=?]', user_path(@post.user), text: /#{@post.user.username}/)
  end

  private

  def assert_title
    assert_select('h', text: post_params[:title])
  end

  def assert_linked_title
    assert_select('a[href=?]', post_params[:link], text: post_params[:title])
  end
end
