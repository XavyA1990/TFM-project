FactoryBot.define do
  factory :course_module do
    association :course
    sequence(:title) { |n| "#{Faker::Educator.subject} #{n}" }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    sequence(:position) { |n| n }
    status { :draft }
  end
end
