require 'test_helper'

class PostsCommentsTest < ActionDispatch::IntegrationTest
  test 'post displays flat comments' do
    post = create(:post_with_comments)
    text_to_comment = post.comments.each_with_object({}) do |comment, hsh|
      hsh[comment.text] = comment
    end
    get post_path(post)
    assert_select 'div.comment', count: 5 do |cmnt_objs|
      cmnt_objs.each do |cmnt_obj|
        assert_select cmnt_obj, 'p.comment-text', count: 1 do |(comment_p)|
          # Remove each matched comment from the list so they only match once
          assert comment = text_to_comment.delete(comment_p.text)
          assert_select cmnt_obj, 'a[href=?]', user_path(user = comment.user),
                        text: /#{user.username}/
        end
      end
    end
  end

  # Assume comments are ordered correctly; this is tested in the model
  test 'post displays threaded comments' do
    # Create a top level comment, a parent with 2 children, and a grandparent
    # with 2 children and 4 grandchildren (2 per parent)
    post = create(:post_with_threaded_comments, threads_each_count: 1)
    get post_path(post)
    assert_equal 3, post.comments.where(parent_id: nil).count,
                 'Expected three top-level comments. Maybe check factories?'

    # Iterate through comment-rows, passing ancestry as a message
    assert_select 'div.comment-row' do |comment_rows|
      comment_rows.inject([]) do |ancestry, comment_row|
        threadlines = css_select comment_row, 'div.threadline-space'
        # Check comment doesn't (seem to) have more threadlines than ancestors
        assert_operator threadlines.count, :<=, ancestry.count
        # Keep as many ancestors as this comment has
        ancestry = ancestry.first(threadlines.count)
        comment_id = get_comment_id(comment_row)
        parent_id = Comment.find(comment_id).parent_id
        # Assert the last ancestor's ID is parent_id (unless top-level comment)
        assert_equal ancestry.last, parent_id if parent_id
        # Append this comment's ID to a_i
        ancestry << comment_id
      end
    end
  end

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
    log_in_as create(:user)
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
    assert_select 'div.comment' do |(cmnt_obj)|
      assert_select cmnt_obj, 'a[href=?]', user_path(current_user),
                    text: /#{current_user.username}/
      assert_select cmnt_obj, 'p.comment-text', count: 1,
                                                text: comment_attributes[:text]
    end
  end

  test 'cannot create blank comment' do
    log_in_as create(:user)
    get post_path(commentless_post)
    # Comment form displayed
    assert_comment_form_rendered
    comment_attributes[:text] = ' '
    assert_no_difference('Comment.count') { create_comment }
    assert_errors_explained(/([Bb]lank|[Ee]mpty)/)
  end

  test 'users can delete their own childless comments' do
    post = create(:post_with_comments, comments_count: 1)
    comment = post.comments.first
    log_in_as(comment.user)
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
    log_in_as(parent_comment.user)
    get post_path(post)
    assert_deletable_comment(parent_comment)
    assert_no_difference('Comment.count') do
      delete comment_path(parent_comment)
    end
    assert_nil parent_comment.reload.user_id, 'Comment has not been redacted; '\
                                              'user_id not nil:'
    assert_redirected_to post_path(post)
    follow_redirect!
    assert flash && flash[:info]
    assert_select 'div.comment', count: 2 do |comments|
      assert_select comments, 'div.comment-metadata>span', count: 1 do |(user)|
        assert_match /[Dd]eleted/, user.text
      end
    end
    # Now delete the child and the parent should be deleted also
    log_in_as(child_comment.user)
    get post_path(post)
    assert_deletable_comment(child_comment)
    assert_difference('Comment.count', -2) do
      delete comment_path(child_comment)
    end
    assert_redirected_to post_path(post)
    follow_redirect!
    assert flash && flash[:success]
    assert_select 'div.comment', false
  end

  test 'users cannot delete eachothers comments' do
    post = create(:post_with_comments, comments_count: 1)
    comment = post.comments.first
    log_in_as
    get post_path(post)
    assert_select 'div.comment-actions a[href=?]', comment_path(comment),
                  method: :delete, count: 0
    assert_no_difference('Comment.count') { delete comment_path(comment) }
    assert_redirect_with_bad_flash
  end

  private

  def commentless_post
    @commentless_post ||= create(:post)
  end

  def comment_attributes
    @comment_attributes ||= attributes_for(:comment)
  end

  def create_comment
    post post_comments_path(commentless_post), params:
          { comment: comment_attributes, post_id: commentless_post.id }
  end

  def assert_deletable_comment(comment)
    assert_select 'div.comment-actions a[href=?]', comment_path(comment),
                  method: :delete
  end

  def assert_comment_form_rendered(count: 1)
    assert_select 'form[action=?]', post_comments_path(commentless_post),
                  count: count
  end

  def refute_comment_form_rendered
    assert_comment_form_rendered(count: 0)
  end

  # Retrieve the ID of a comment from a node object containing exactly 1 comment
  def get_comment_id(comment_row)
    css_select(comment_row, 'div.comment').first[:id].to_i
  end
end
