require 'test_helper'

module PostsTestHelpers
  # Set controller_test option to true to check the post passes controller validations
  def make_post(factory = :post, **options)
    post posts_path, params: { post: post_params(factory, **options) }
  end

  def post_params(factory = :post, **options)
    @post_params ||= attributes_for(factory, **options)
  end

  # Expects @post to have a 1 line body, & to have been created via the new post
  # form in the last request
  def assert_post_contents_displayed
    assert_link_to_external_link
    assert_select('p', text: post_params[:body])
    assert_select('a[href=?]', user_path(@post.user),
                  text: /#{@post.user.username}/)
  end

  private

  def assert_link_to_external_link
    return unless (link = @post.link)

    assert_select 'a.external-link', count: 1 do |(external_link)|
      assert_equal link, external_link['href']
      assert_equal post_params[:link].slice(12..), external_link.text
    end
  end
end
