FactoryBot.define do
  factory :lesson do
    association :course_module
    sequence(:title) { |n| "#{Faker::Book.title} #{n}" }
    description { Faker::Lorem.sentence(word_count: 10) }
    body { Faker::Lorem.paragraphs(number: 2).join("\n\n") }
    lesson_type { :text }
    sequence(:position) { |n| n }
    status { :draft }
  end
end
