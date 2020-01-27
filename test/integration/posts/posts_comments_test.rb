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
    assert_select 'form[action=?]', comments_path, false
    # Login and signup links displayed
    assert_select 'form[action=?]', login_path, method: :get
    assert_select 'form[action=?]', signup_path, method: :get
    assert_no_difference 'Comment.count' do
      post comments_path, params: { comment: comment_attributes }
    end
    assert_redirected_to login_path
  end

  test 'can comment on post' do
    log_in_as create(:user)
    get post_path(commentless_post)
    # Login and signup links NOT displayed
    assert_select 'form[action=?]', login_path, false
    assert_select 'form[action=?]', signup_path, false
    # Comment form displayed
    assert_select 'form[action=?]', comments_path
    assert_select '#error-explanation', false
    assert_difference('Comment.count', 1) do
      assert_difference('Post.last.comments.count', 1) do
        post comments_path, params: { comment: comment_attributes }
      end
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
    comment_attributes[:text] = ' '
    assert_no_difference 'Comment.count' do
      post comments_path, params: { comment: comment_attributes }
    end
    assert_errors_explained(/([Bb]lank|[Ee]mpty)/)
  end

  private

  def commentless_post
    @commentless_post ||= create(:post)
  end

  def comment_attributes
    @comment_attributes ||=
      attributes_for(:comment).merge(post_id: commentless_post.id)
  end
end
