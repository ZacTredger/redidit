require_relative '../db/post_maker.rb'

# Users
FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "Rediditor#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    created_at { Fake.creation_date }
    updated_at { created_at }
    factory :user_with_posts do
      transient { posts_count { 5 } }
      after(:create) do |user, evaluator|
        create_list(:post, evaluator.posts_count, user: user)
      end
    end
    factory :user_with_comments do
      transient { comments_count { 5 } }
      after(:create) do |user, evaluator|
        create_list(:comment, evaluator.comments_count, user: user)
      end
    end
    factory(:user_without_username) { username { '' } }
    factory(:user_without_email) { email { '' } }
    factory(:user_without_password) { password { '' } }
    factory(:user_without_password_confirmation) { password_confirmation { '' } }
    factory(:user_with_short_password) do
      password { 'short' }
      password_confirmation { 'short' }
    end
  end
end

# Votables
FactoryBot.define do
  # Posts
  factory :post do
    trait(:no_link) { link { '' } }
    trait(:no_body) { body { '' } }
    sequence(:title) { |n| "Title #{n}" }
    user
    created_at { Fake.creation_date_after(user) }
    link { 'https://www.reddit.com' }
    body { 'body' }
    factory(:post_without_link) { no_link }
    factory(:post_without_body) { no_body }
    factory(:post_with_multi_para_body) { body { "Each\nin\nown\np-emelent" } }
    factory :post_with_comments do
      transient { comments_count { 5 } }
      after(:create) do |post, evaluator|
        create_list(:comment, evaluator.comments_count, post: post)
      end
    end
    factory :post_with_threaded_comments do
      transient { threads_each_count { 1 } }
      after(:create) do |post, evaluator|
        create_list(:comment, evaluator.threads_each_count, post: post)
        create_list(:comment_with_children, evaluator.threads_each_count,
                    post: post)
        create_list(:comment_with_grandchildren, evaluator.threads_each_count,
                    post: post)
      end
    end
    # Invalid posts
    factory(:post_without_body_or_link) { no_link; no_body }
    factory(:post_without_title) { title { '' } }
  end

  # Comments
  factory :comment do
    sequence(:text) { |n| "Comment #{n}" }
    user
    post
    created_at { Fake.creation_date_after(user, post) }
    factory :comment_with_parent, aliases: [:child] do
      parent
      created_at { Fake.creation_date_after(user, post, parent) }
    end
    factory :comment_with_children, aliases: [:parent] do
      transient { child_count { 2 } }
      after(:create) do |parent, evaluator|
        create_list(:child, evaluator.child_count, parent: parent,
                                                   post: parent.post)
      end
    end
    factory :comment_with_grandchildren, aliases: [:grandparent] do
      transient { child_count { 2 } }
      after(:create) do |grandparent, evaluator|
        create_list(:parent, evaluator.child_count, parent: grandparent,
                                                    post: grandparent.post)
      end
    end
  end

  # Gives votables votes when built
  trait :with_votes do
    transient { upvotes { 2 } }
    transient { downvotes { 1 } }
    after(:create) do |votable, evaluator|
      vote_context = "on_#{votable.class.to_s.downcase}".to_sym
      create_list(:vote, evaluator.upvotes, vote_context, :upvote,
                  votable: votable)
      create_list(:vote, evaluator.downvotes, vote_context, :downvote,
                  votable: votable)
    end
  end
end

# Votes
FactoryBot.define do
  factory :vote do
    user
    created_at { Fake.creation_date_after(user, votable) }
    trait(:on_post) { association :votable, factory: :post }
    trait(:on_comment) { association :votable, factory: :comment }
    trait(:upvote) { up { true } }
    trait(:downvote) { up { false } }
    # Be an upvote by default
    upvote
  end
end
