# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

User.create!(
  username: 'Example name',
  email: 'ex@mp.le',
  password: 'password',
  password_confirmation: 'password'
)

(1..99).each do |n|
  User.create!(
    username: Faker::Name.name,
    email: "User-#{n}@example.com",
    password: 'password',
    password_confirmation: 'password'
  )
end
