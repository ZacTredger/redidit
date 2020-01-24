require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test 'recent scope selectsmost recent posts in correct order' do
    # Check there are no posts in the test DB before the test starts
    assert_equal 0, Post.count
    # Create 25 posts with random created_at dates
    posts = (0...25).to_a.map! { create(:post) }
    assert_equal posts.max_by(&:created_at), Post.recent.first
  end
end
