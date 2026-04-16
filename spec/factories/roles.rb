FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}_#{Faker::Job.unique.position.parameterize(separator: '_')}" }
    description { Faker::Lorem.sentence(word_count: 6) }
  end
end
