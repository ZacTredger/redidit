require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  def setup
    @comment = Comment.new(attributes_for(:comment, user_id: create(:user).id,
                                                    post_id: create(:post).id))
  end

  test 'Comment without & with parent accepted' do
    assert @comment.save, 'Valid comment without parent rejected'
    @comment.parent_id = Comment.last.id
    assert @comment.valid?, 'Valid comment with (valid) parent rejected'
  end

  test 'Comment with non-existent parent rejected' do
    last_comment = Comment.last
    last_id = last_comment ? last_comment.id : 0
    @comment.parent_id = last_id + 1
    assert @comment.invalid?
  end

  test 'Comment without user rejected' do
    @comment.user_id = ' '
    assert @comment.invalid?
  end

  test 'Comment without post rejected' do
    @comment.post_id = ' '
    assert @comment.invalid?
  end

  test 'Comment without text rejected' do
    @comment.text = ' '
    assert @comment.invalid?
  end

  test 'Comment with non-existent user rejected' do
    last_user = User.last
    last_id = last_user ? last_user.id : 0
    @comment.user_id = last_id + 1
    assert @comment.invalid?
  end

  test 'Comment with non-existent post rejected' do
    last_post = Post.last
    last_id = last_post ? last_post.id : 0
    @comment.post_id = last_id + 1
    assert @comment.invalid?
  end

  test 'Recent comments are ordered correctly' do
    # Create a top level comment, a parent with 2 children, and a grandparent
    # with 2 children and 4 grandchildren (2 per parent)
    post = create(:post_with_threaded_comments, threads_each_count: 1)
    assert_equal 3, post.comments.where(parent_id: nil).count,
                 'Expected three top-level comments. Maybe check factories?'
    post.comments.recent.each_with_object([]) do |comment, ancestry|
      # If the comment has siblings...
      if (parent = comment.parent) && parent != ancestry.last
        # Check the comment's parent has already been seen
        assert parent_gen = ancestry.index(parent)
        generation = parent_gen + 1
        # Check the comment is older than its (higher) sibling
        assert_operator comment.created_at, :<=, ancestry[generation].created_at
        # Remove comment's sibling (and sibling's descendents) from ancestry
        ancestry.slice!(generation..)
      end
      ancestry << comment
    end
  end
end
