require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test 'recent scope selectsmost recent posts in correct order' do
    # Check there are no posts in the test DB before the test starts
    assert_equal 0, Post.count
    # Create 25 posts with random created_at dates
    posts = (0...25).to_a.map! { create(:post) }
    assert_equal posts.max_by(&:created_at), Post.recent.first
  end

  test 'karma is calculated correctly' do
    assert_equal 1, voted_post.karma
  end

  private

  def voted_post
    create(:post, :with_votes, upvotes: 3, downvotes: 2)
  end
end
