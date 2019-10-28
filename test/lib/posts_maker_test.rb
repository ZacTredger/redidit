require 'test_helper'
%w[post_maker redidits].each { |f| require_relative "../../db/#{f}.rb" }

class PostMakerTest < ActionDispatch::IntegrationTest
  POSTS_DATA = {
    post_doggos: { title: 'long boi', link: /.+dog$/ },
    post_cats: { title: 'Max, my Korn Ja', link: /.+cat$/ },
    post_philosophy: { title: 'Hippocrates - A few vices',
                       link: 'https://en.wikipedia.org/wiki/Hippocrates' },
    post_ask_hipster: { title: /^Pabst /, body: /^Pinterest stumptown craft/,
                        com_reg: /^[A-Z].+\w+\./ },
    post_ask_redidit_in_latin:
      { title: /Repellat.+\?/, body: /^Possimus in corporis/,
        com_reg: /^[A-Z].+\w+\./, op_rep_reg: 'Ego dissentio' },
    post_hacker_help: { title: 'How do I synthesize the optical circuit?',
                        body: 'Sorry', com_reg: /^[A-Z].+\w+\!/,
                        op_rep_reg: /I tried that/ },
    post_trees: { title: 'Heavy OG stimulates appetite', body: /.+/,
                  com_reg: /though\.$/,
                  op_rep_reg: /right now\.\.\.$/ },
    post_technology: { title: "Bream-Hall releases Pegg'd",
                       link: 'http://raviga.com', body: 'Awesome world' },
    post_dating: { title: /^5 ft\, 0 in.+love$/, body: 'No smokers please',
                   com_reg: /^. ft.+rested\?$/, op_rep_reg: 'PM me' }
  }.freeze

  # Dynamically define tests for each subredidit, to keep code DRY and include
  # sub names in failure messages so they're easier to understand
  SETUP = begin
    POSTS_DATA.each do |post_method, hsh|
      define_method "test_#{post_method}_posts_and_comments_correctly".to_sym do
        assert_posts_created(post_method, hsh)
      end
    end
  end

  private

  attr_reader :post

  def assert_posts_created(post_method, com_reg: /.+/, op_rep_reg: nil, **hsh)
    Faker::Config.random = Random.new(0)
    assert_difference 'Post.count', 1 do
      Fake::PostMaker.send(post_method)
    end
    @post = Post.last
    assert_posts_correctly(hsh)
    assert_comments_correctly(com_reg, op_rep_reg)
  end

  def assert_posts_correctly(hsh)
    hsh.each { |attr, regex| assert_match regex, post.send(attr) }
    assert_after_owners(post, :user)
  end

  def assert_comments_correctly(com_reg, op_rep_reg)
    post.comments.each do |comment|
      assert_after_owners(comment, :user, :post, :parent)
      comment_text = comment.text
      if op_rep_reg&.match(comment_text)
        assert comment.parent
        assert_equal comment.user, post.user
      else assert_match com_reg, comment_text
      end
    end
  end

  # Pass an active_record record & symbols for each method it responds to with
  # one of its dependencies (i.e. those that should exist before the record)
  def assert_after_owners(record, *owner_getters)
    owner_getters.each do |owner_getter|
      next unless (owner = record.send(owner_getter))

      assert_operator record.created_at, :>, owner.created_at,
                      bad_chronology_msg(record, owner, owner_getter)
    end
  end

  def bad_chronology_msg(record, owner, owner_getter)
    "#{record.class} apparently created (#{record.created_at}) before "\
    "its #{owner_getter} (#{owner.created_at})."
  end
end
