FactoryBot.define do
  factory :permission do
    sequence(:name) { |n| "permission_#{n}_#{Faker::Verb.base}" }
    action { %w[read create update destroy manage].sample }
    subject_class { %w[User Tenant Course Enrollment Report].sample }
    description { Faker::Lorem.sentence(word_count: 8) }
  end
end
