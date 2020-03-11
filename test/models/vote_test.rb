require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  test 'post-vote saves' do
    assert_difference 'post.reload.votes.count', 1 do
      post.votes.create(attributes_for(:vote, user_id: create(:user).id))
    end
  end

  test 'vote without user will not save' do
    assert_no_difference 'post.votes.count' do
      post.votes.create(attributes_for(:vote))
    end
  end

  test 'vote without explicit up or down will not save' do
    assert_no_difference 'post.votes.count' do
      post.votes.create(attributes_for(:vote, up: nil))
    end
  end

  private

  def post
    @post ||= create(:post)
  end
end
