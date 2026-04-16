FactoryBot.define do
  factory :tenant do
    sequence(:name) { |n| "#{Faker::Company.unique.name} #{n}" }
    logo_url { Faker::Internet.url }
  end
end
