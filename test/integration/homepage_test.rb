require 'test_helper'

class HomepageTest < ActionDispatch::IntegrationTest
  test 'recent feed view uses the recent scope' do
    25.times { create(:post) }
    get(root_path)
    assert_select 'li.post-info', count: 20 do |posts_info|
      post_info = posts_info.first
      assert_select post_info, 'a', count: 1 do |(post_link)|
        most_recent_post = Post.recent.first
        assert_equal most_recent_post.title, post_link.text
        assert_equal post_path(most_recent_post), post_link['href']
      end
    end
  end
end
