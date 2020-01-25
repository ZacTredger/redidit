require 'test_helper'

class HomepageTest < ActionDispatch::IntegrationTest
  test 'recent feed view uses the recent scope' do
    25.times { create(:post) }
    get(root_path)
    assert_select 'li.post-info', count: 20 do |posts_info|
      post_info = posts_info.first
      latest_post = Post.recent.first
      assert_select post_info, 'a.post-link', count: 1 do |(post_link)|
        assert_equal latest_post.title, post_link.text
        assert_equal post_path(latest_post), post_link['href']
      end
      # Check post metadata
      assert_select post_info, 'a[href=?]', user_path(o_p = latest_post.user),
                    text: /#{o_p.username}/
    end
  end
end
