require 'test_helper'
require_relative 'posts_test_helper.rb'

class PostsNewTest < ActionDispatch::IntegrationTest
  include PostsTestHelpers
  test "can't create a post when not logged in" do
    get new_post_path
    assert_redirected_to login_path
  end

  test 'can create post, which displays' do
    log_in
    get new_post_path
    assert_select 'form[action=?]', posts_path
    assert_select '#error-explanation', false
    assert_difference('Post.count', 1) { make_post }
    assert_redirected_to post_path(@post = Post.last)
    follow_redirect!
    assert_post_contents_displayed
    # OP should upvote their own post automatically
    assert_equal 1, @post.karma
    assert_equal @post.user, @post.votes.first.user
  end

  test 'multi-paragraph post body displays each para in own p-element' do
    get post_path(@post = create(:post, :multi_paragraph_body))
    @post.body.each_line do |line|
      assert_select('p', text: line.chomp)
    end
  end

  test 'post without title rejected with errors explained' do
    rejects_invalid_post_and_explains_errors(title: '', error_text: /[Tt]itle/)
  end

  test 'post with neither body nor link rejected with errors explained' do
    rejects_invalid_post_and_explains_errors(body: '', link: '',
                                             error_text: /[Bb]ody.*[Ll]ink/)
  end

  def rejects_invalid_post_and_explains_errors(error_text:, **options)
    log_in
    get new_post_path
    assert_no_difference('Post.count') { make_post(**options) }
    assert_errors_explained(error_text)
  end
end
