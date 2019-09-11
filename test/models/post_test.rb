require 'test_helper'

class PostTest < ActiveSupport::TestCase
  def setup
    @post = Post.new(title: 'First!', body: 'Irrelevant',
                     link: 'http://www.google.com', user_id: User.last.id)
  end

  test 'post is valid' do
    assert @post.valid?
  end

  test 'post without postname is not valid' do
    @post.title = ' '
    assert @post.invalid?
  end

  test 'post without link is still valid' do
    @post.link = ' '
    assert @post.valid?
  end

  test 'post without body is still valid' do
    @post.body = ' '
    assert @post.valid?
  end

  test 'post without user_id is invalid' do
    @post.user_id = ' '
    assert @post.invalid?
  end

  test 'post with non-existent user_id is invalid' do
    @post.user_id += 1
    assert @post.invalid?
  end
end
