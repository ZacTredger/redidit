require 'test_helper'
require_relative 'posts_test_helper.rb'

class PostsNewTest < ActionDispatch::IntegrationTest
  include PostsTestHelpers
  test "can't create a post when not logged in" do
    get new_post_path
    assert_redirected_to login_path
  end

  test 'can create post, which displays' do
    log_in_as create(:user)
    get new_post_path
    assert_select 'form[action=?]', posts_path
    assert_select '#error-explanation', false
    assert_difference('Post.count', 1) { make_post }
    assert_redirected_to post_path(@post = Post.last)
    follow_redirect!
    assert_post_contents_displayed
  end

  test 'multi-paragraph post body displays each para in own p-element' do
    get post_path(@post = create(:post_with_multi_para_body))
    @post.body.each_line do |line|
      assert_select('p', text: line.chomp)
    end
  end

  test 'post without title rejected with errors explained' do
    rejects_invalid_post_and_explains_errors(:post_without_title, /[Tt]itle/)
  end

  test 'post with neither body nor link rejected with errors explained' do
    rejects_invalid_post_and_explains_errors(:post_without_body_or_link,
                                             /[Bb]ody.*[Ll]ink/)
  end

  def rejects_invalid_post_and_explains_errors(factory, error_text)
    log_in_as create(:user)
    get new_post_path
    assert_no_difference('Post.count') { make_post(factory) }
    assert_errors_explained(error_text)
  end
end
