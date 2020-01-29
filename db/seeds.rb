%w[post_maker.rb redidits.rb].each { |f| require_relative f }

app_age = 3.months
latest_signup = app_age.ago

User.create!(
  username: 'Example_name',
  email: 'example@railstutorial.org',
  password: 'password',
  password_confirmation: 'password',
  created_at: latest_signup
)

def usernames_from(franchise)
  usernames = Faker::Base.fetch_all(franchise + '.characters')
  usernames.map! { |username| username.gsub("'", '').gsub(/[^\w\-]/, '-') }
  usernames.select! { |name| name.length < 21 } || usernames
end

names = %w[
  hitchhikers_guide_to_the_galaxy
  princess_bride
  bojack_horseman
].inject([]) { |arr, franchise| arr + usernames_from(franchise) }

creation_interval = app_age.seconds / names.count

names.each do |name|
  password = name.sub(' ', '_') + '_password'
  created_at = Fake.creation_date(from: latest_signup + 1.second,
                                  to: latest_signup + creation_interval)
  User.create!(
    username: name,
    email: Faker::Internet.unique.email,
    password: password,
    password_confirmation: password,
    created_at: created_at,
    updated_at: created_at
  )
end

subs = %w[doggos cats philosophy hacker_help ask_hipster ask_redidit_in_latin
          trees technology dating]

75.times { Fake::PostMaker.send('post_' + subs.sample) }
