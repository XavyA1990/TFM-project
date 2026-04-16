FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:username) { |n| "#{Faker::Internet.username(specifier: 6..12)}#{n}" }
    sequence(:email) { |n| Faker::Internet.unique.email(name: "user#{n}") }
    password { "Password123!" }
    password_confirmation { password }
    confirmed_at { Time.current }
  end
end
