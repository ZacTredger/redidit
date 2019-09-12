require 'test_helper'

class PostVoteTest < ActiveSupport::TestCase
  def setup
    User.create(username: 'Name', email: 'ex@mp.le', password: 'Abcdefgh',
                password_confirmation: 'Abcdefgh')
    Post.create(title: 'Title', body: 'Body', user_id: User.last.id)
    @post_vote = PostVote.new(user_id: User.last.id, post_id: Post.last.id,
                              up: true)
  end

  test 'Valid post-vote accepted' do
    assert @post_vote.valid?
  end

  test 'Post-vote without user rejected' do
    @post_vote.user_id = ' '
    assert @post_vote.invalid?
  end

  test 'Post-vote without post rejected' do
    @post_vote.post_id = ' '
    assert @post_vote.invalid?
  end

  # String with whitespace is cast to true. Don't know how to stop this.
  test 'Post-vote without vote rejected' do
    @post_vote.up = ''
    assert @post_vote.invalid?
  end

  test 'Post-vote with non-existent user rejected' do
    last_user = User.last
    last_id = last_user ? last_user.id : 0
    @post_vote.user_id = last_id + 1
    assert @post_vote.invalid?
  end

  test 'Post-vote with non-existent post rejected' do
    last_post = Post.last
    last_id = last_post ? last_post.id : 0
    @post_vote.post_id = last_id + 1
    assert @post_vote.invalid?
  end

  test 'Post-vote with non-boolean vote rejected' do
    @post_vote.up = nil
    assert @post_vote.invalid?
  end
end
