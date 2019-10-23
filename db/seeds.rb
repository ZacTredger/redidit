%w[helpers.rb redidits.rb].each { |f| require_relative f }

User.create!(
  username: 'Example name',
  email: 'example@railstutorial.org',
  password: 'password',
  password_confirmation: 'password'
)

names = %w[
  hitchhikers_guide_to_the_galaxy
  princess_bride
  bojack_horseman
].inject([]) { |arr, x| arr + Faker::Base.fetch_all(x + '.characters') }

names.each_with_index do |name, n|
  User.create!(
    username: name,
    email: "example-#{n + 100}@railstutorial.org",
    password: 'password',
    password_confirmation: 'password'
  )
end

subs = %w[doggos cats philosophy hacker_help ask_hipster ask_redidit_in_latin
          trees technology dating]

50.times { Fake::PostMaker.send('post_' + subs.sample) }
