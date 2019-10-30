require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get posts_path
    assert_response :success
  end

  test 'should get show' do
    get post_path(create(:post))
    assert_response :success
  end
end
