require 'test_helper'

class PostTest < ActiveSupport::TestCase
  def setup
    @post = Post.new(title: 'First!', body: 'Irrelevant',
                     link: 'http://www.google.com', user_id: User.last.id)
  end

  test 'post accepted' do
    assert @post.valid?
  end

  test 'post without postname rejected' do
    @post.title = ' '
    assert @post.invalid?
  end

  test 'post with body, but no link accepted' do
    @post.link = ' '
    assert @post.valid?
  end

  test 'post with link, but no body accepted' do
    @post.body = ' '
    assert @post.valid?
  end

  test 'post without link or body rejected' do
    @post.body = @post.link = ' '
    assert @post.invalid?
  end

  test 'post without user_id rejected' do
    @post.user_id = ' '
    assert @post.invalid?
  end

  test 'post with non-existent user_id rejected' do
    @post.user_id += 1
    assert @post.invalid?
  end
end
