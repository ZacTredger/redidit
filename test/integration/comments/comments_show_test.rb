require 'test_helper'
require_relative 'comments_test_helper'

# Relating to displaying comments on post-pages
class CommentsShowTest < ActionDispatch::IntegrationTest
  test 'post displays flat comments' do
    post = create(:post, :comments)
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
    post = create(:post, :threaded_comments, threads_each_count: 1)
    get post_path(post)
    assert_equal 3, post.comments.where(parent_id: nil).count,
                 'Expected three top-level comments. Maybe check factories?'

    # Iterate through comment-rows, passing ancestry as a message
    assert_select '.comment-row' do |comment_rows|
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

  private

  # Retrieve the ID of a comment from a node object containing exactly 1 comment
  def get_comment_id(comment_row)
    css_select(comment_row, 'div.comment').first[:id].to_i
  end
end
