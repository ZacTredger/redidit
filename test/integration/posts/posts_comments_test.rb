require 'test_helper'

class PostsCommentsTest < ActionDispatch::IntegrationTest
  test 'post displays comments' do
    post = create(:post_with_comments)
    get post_path(post)
    assert_select 'div.comment', count: 5
  end
end
