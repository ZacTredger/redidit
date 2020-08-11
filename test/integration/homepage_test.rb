require 'test_helper'

class HomepageTest < ActionDispatch::IntegrationTest
  test 'recent feed view uses the recent scope' do
    25.times { create(:post) }
    get(root_path)
    assert_select '.post-row', count: 20 do |(post_info, *_)|
      latest_post = Post.recent.first
      assert_select post_info, 'a.post-page', count: 1 do |(post_link)|
        assert_equal latest_post.title, post_link.text
        assert_equal post_path(latest_post), post_link['href']
      end
      assert_select post_info, 'a.external-link', count: 1 do |(external_link)|
        assert_equal 'reddit.com', external_link.text
        assert_equal latest_post.link, external_link['href']
      end
      %i[up down].each do |direction|
        assert_select post_info, "##{direction}vote-post-#{latest_post.id}"
      end
      assert_select post_info, '.karma', text: '1'
      # Check post metadata
      assert_select post_info, 'a[href=?]', user_path(o_p = latest_post.user),
                    text: /#{o_p.username}/
    end
  end
end
