require 'test_helper'

module PostsTestHelpers
  # Set controller_test option to true to check the post passes controller validations
  def make_post(factory = :post)
    post posts_path, params: { post: post_params(factory) }
  end

  def post_params(factory = :post)
    @post_params ||= attributes_for(factory)
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
