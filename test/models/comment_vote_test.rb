require 'test_helper'

class CommentVoteTest < ActiveSupport::TestCase
  def setup
    User.create(username: 'Name', email: 'ex@mp.le', password: 'Abcdefgh',
                password_confirmation: 'Abcdefgh')
    Post.create(title: 'Title', body: 'Body', user_id: User.last.id)
    Comment.create(text: 'Text', user_id: User.last.id, post_id: Post.last.id)
    @comment_vote = CommentVote.new(user_id: User.last.id,
                                    comment_id: Comment.last.id, up: true)
  end

  test 'Valid Comment-vote accepted' do
    assert @comment_vote.valid?
  end

  test 'Comment-vote without user rejected' do
    @comment_vote.user_id = ' '
    assert @comment_vote.invalid?
  end

  test 'Comment-vote without comment rejected' do
    @comment_vote.comment_id = ' '
    assert @comment_vote.invalid?
  end

  # String with whitespace is cast to true. Don't know how to stop this.
  test 'Comment-vote without vote rejected' do
    @comment_vote.up = ''
    assert @comment_vote.invalid?
  end

  test 'Comment-vote with non-existent user rejected' do
    last_user = User.last
    last_id = last_user ? last_user.id : 0
    @comment_vote.user_id = last_id + 1
    assert @comment_vote.invalid?
  end

  test 'Comment-vote with non-existent comment rejected' do
    last_comment = Comment.last
    last_id = last_comment ? last_comment.id : 0
    @comment_vote.comment_id = last_id + 1
    assert @comment_vote.invalid?
  end

  test 'Comment-vote with non-boolean vote rejected' do
    @comment_vote.up = nil
    assert @comment_vote.invalid?
  end
end
