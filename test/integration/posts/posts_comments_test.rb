require 'test_helper'

class PostsCommentsTest < ActionDispatch::IntegrationTest
  test 'post displays comments' do
    post = create(:post_with_comments)
    text_to_comment = post.comments.each_with_object({}) do |comment, hsh|
      hsh[comment.text] = comment
    end
    get post_path(post)
    assert_select 'div.comment', count: 5 do |cmnt_objs|
      cmnt_objs.each do |cmnt_obj|
        assert_select cmnt_obj, 'p.comment-text', count: 1 do |(comment_p)|
          # Remove each matched comment from the list so they only match once
          assert comment = text_to_comment.delete(comment_p.text)
          assert_select cmnt_obj, 'a[href=?]', user_path(user = comment.user),
                        text: /#{user.username}/
        end
      end
    end
  end
end
