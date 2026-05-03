FactoryBot.define do
  factory :course do
    association :tenant
    sequence(:title) { |n| "#{Faker::Educator.course_name} #{n}" }
    short_description { Faker::Lorem.sentence(word_count: 8) }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    status { :draft }
  end
end
