require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  def setup
    User.create(username: 'Name', email: 'ex@mp.le', password: 'Abcdefgh',
                password_confirmation: 'Abcdefgh')
    Post.create(title: 'Title', body: 'Body', user_id: User.last.id)
    @comment = Comment.new(text: 'Comment', user_id: User.last.id,
                           post_id: Post.last.id)
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
end
