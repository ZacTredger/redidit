require 'test_helper'
require_relative 'comments_test_helper'

# Tests editing and deleting comments
class CommentsEditTest < ActionDispatch::IntegrationTest
  test 'users can delete their own childless comments' do
    post = create(:post, :comments, comments_count: 1)
    comment = post.comments.first
    log_in as: comment.user
    get post_path(post)
    assert_deletable_comment(comment)
    assert_difference('Comment.count', -1) { delete comment_path(comment) }
    assert_redirected_to post_path(post)
    follow_redirect!
    assert_select 'div.comment', false
  end

  test 'users can delete their own comments (with children)' do
    parent_comment = create(:comment_with_children, child_count: 1)
    child_comment = parent_comment.children.first
    post = parent_comment.post
    log_in as: (commenter = parent_comment.user)
    get post_path(post)
    assert_deletable_comment(parent_comment)
    # The comment should only be redacted, so the comment count should be
    # unchanged, but the commenter should lose their karma from it.
    assert_no_difference 'Comment.count' do
      assert_difference 'commenter.reload.karma', -1 do
        assert_difference 'parent_comment.reload.karma', -1 do
          assert_difference 'Vote.count', -1 do
            delete comment_path(parent_comment)
          end
        end
      end
    end
    assert_nil parent_comment.reload.user_id,
               'Comment has not been redacted; user_id not nil:'
    assert_redirected_to post_path(post)
    follow_redirect!
    assert flash && flash[:info]
    assert_select '.comment-row', count: 2 do |comments|
      assert_select comments.first, '.comment-metadata>span' do |(user)|
        assert_match(/[Dd]eleted/, user.text)
      end
      # Vote controls aren't displayed on redacted comments
      assert_select comments.first, 'button', false
      assert_select comments.first, '.no-controls', text: ''
    end
    # And redacted comments can't be voted on
    assert_no_difference 'Vote.count' do
      post comment_votes_path(parent_comment),
           params: { vote: attributes_for(:vote) }
    end
    assert_redirect_with_bad_flash
    # Now both the child comment and its redacted parent can be deleted.
    log_in as: child_comment.user
    get post_path(post)
    assert_deletable_comment(child_comment)
    assert_difference 'Comment.count', -2 do
      assert_no_difference 'commenter.reload.karma' do
        delete comment_path(child_comment)
      end
    end
    assert_redirected_to post_path(post)
    follow_redirect!
    assert flash && flash[:success]
    assert_select 'div.comment', false
  end

  test 'users cannot delete eachothers comments' do
    post = create(:post, :comments, comments_count: 1)
    comment = post.comments.first
    log_in
    get post_path(post)
    assert_select '.comment-actions a[href=?]', comment_path(comment),
                  method: :delete, count: 0
    assert_no_difference('Comment.count') do
      assert_no_difference('Vote.count') { delete comment_path(comment) }
    end
    assert_redirect_with_bad_flash
  end

  private

  def assert_deletable_comment(comment)
    assert_select '.comment-actions a[href=?]', comment_path(comment),
                  method: :delete
  end
end
