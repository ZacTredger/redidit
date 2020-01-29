require 'test_helper'

class PostsCommentsTest < ActionDispatch::IntegrationTest
  test 'post displays comments' do
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
    assert_redirected_to post_path(post)
    follow_redirect!
    assert flash && flash[:success]
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
end
