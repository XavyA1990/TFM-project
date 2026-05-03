FactoryBot.define do
  factory :tenant do
    sequence(:name) { |n| "#{Faker::Company.unique.name} #{n}" }
  end
end
