require_relative '../db/post_maker.rb'

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
      after_create do |user, evaluator|
        create_list(:comment, evaluator.comments_count, user: user)
      end
    end
  end
end

FactoryBot.define do
  factory :post do
    title { 'Title' }
    user
    created_at { Fake.creation_date_after(user) }
    link { 'https://www.reddit.com' }
    body { 'body' }
    trait(:no_link) { link { nil } }
    trait(:no_body) { body { nil } }
    factory(:post_without_link) { no_link }
    factory(:post_without_body) { no_body }
    factory(:post_without_body_or_link) do
      no_link
      no_body
    end
    factory(:post_with_multi_para_body) { body { "Each\nin\nown\np-emelent" } }
    factory :post_with_comments do
      transient { comments_count { 5 } }
      after_create do |post, evaluator|
        create_list(:comment, evaluator.comments_count, post: post)
      end
    end
  end
end

FactoryBot.define do
  factory :comment, aliases: [:parent] do
    text { 'Text' }
    user
    post
    created_at { Fake.creation_date_after(user, post) }
    factory :comment_with_parent do
      parent
      created_at { Fake.creation_date_after(user, post, parent) }
    end
    factory :comment_with_children do
      transient { child_count { 5 } }
      after_create do |parent, evaluator|
        create_list(:children, evaluator.cild_count, parent: parent)
      end
    end
  end
end
