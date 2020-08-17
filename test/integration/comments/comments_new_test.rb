require 'test_helper'
require_relative 'comments_test_helper'

# Tests the comment form (displayed on post-pages) and comment creation
class CommentsNewTest < ActionDispatch::IntegrationTest
  include CommentsTestHelpers
  test 'cannot comment unless logged in' do
    get post_path(commentless_post)
    # Comment form NOT displayed
    refute_comment_form_rendered
    # Login and signup links displayed
    assert_select 'form[action=?]', login_path, method: :get
    assert_select 'form[action=?]', signup_path, method: :get
    assert_no_difference('Comment.count') { create_comment }
    assert_redirected_to login_path
  end

  test 'can comment on post' do
    log_in as: (user = create(:user))
    get post_path(commentless_post)
    # Login and signup links NOT displayed
    assert_select 'form[action=?]', login_path, false
    assert_select 'form[action=?]', signup_path, false
    # Comment form displayed
    assert_comment_form_rendered
    assert_select '#error-explanation', false
    assert_difference('Comment.count', 1) do
      assert_difference('Post.last.comments.count', 1) { create_comment }
    end
    assert_select '#error-explanation', false
    assert_redirected_to %r{#{post_path(commentless_post)}(/comments)?}
    follow_redirect!
    assert_select '.comment' do |(cmnt_obj)|
      assert_select cmnt_obj, 'a[href=?]', user_path(user),
                    text: /#{user.username}/
      assert_select cmnt_obj, 'p.comment-text', count: 1,
                                                text: comment_attributes[:text]
    end
    # Commenter should upvote their own comment automatically
    assert_equal 1, (comment = Comment.last).karma
    assert_equal comment.user, comment.votes.first.user
  end

  test 'cannot create blank comment' do
    log_in
    get post_path(commentless_post)
    # Comment form displayed
    assert_comment_form_rendered
    comment_attributes[:text] = ' '
    assert_no_difference('Comment.count') { create_comment }
    assert_errors_explained(/([Bb]lank|[Ee]mpty)/)
  end

  private

  def comment_attributes
    @comment_attributes ||= attributes_for(:comment)
  end

  def create_comment
    post post_comments_path(commentless_post), params:
          { comment: comment_attributes, post_id: commentless_post.id }
  end

  def assert_comment_form_rendered(count: 1)
    assert_select 'form[action=?]', post_comments_path(commentless_post),
                  count: count
  end

  def refute_comment_form_rendered
    assert_comment_form_rendered(count: 0)
  end
end
