User.create!(
  username: 'Example name',
  email: 'example@railstutorial.org',
  password: 'password',
  password_confirmation: 'password'
)

(1..99).each do |n|
  User.create!(
    username: Faker::Name.name,
    email: "example-#{n}@railstutorial.org",
    password: 'password',
    password_confirmation: 'password'
  )
end
