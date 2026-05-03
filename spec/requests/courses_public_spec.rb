require "rails_helper"

RSpec.describe "Public tenant courses", type: :request do
  let(:locale) { I18n.default_locale }

  describe "GET /:tenant_slug/courses/:id" do
    it "renders a public course page with published modules and lessons only" do
      tenant_name = "#{Faker::Company.unique.name} Academy"
      course_title = "#{Faker::Educator.course_name} #{SecureRandom.hex(2)}"
      published_module_title = "#{Faker::Educator.subject} #{SecureRandom.hex(2)}"
      hidden_module_title = "#{Faker::Educator.subject} #{SecureRandom.hex(2)}"
      published_lesson_title = "#{Faker::Book.title} #{SecureRandom.hex(2)}"
      hidden_lesson_title = "#{Faker::Book.title} #{SecureRandom.hex(2)}"
      private_lesson_title = "#{Faker::Book.title} #{SecureRandom.hex(2)}"

      tenant = create(:tenant, name: tenant_name)
      course = create(:course, tenant: tenant, title: course_title, status: :published)
      published_module = create(:course_module, course: course, title: published_module_title, position: 1, status: :published)
      hidden_module = create(:course_module, course: course, title: hidden_module_title, position: 2, status: :draft)
      create(:lesson, course_module: published_module, title: published_lesson_title, position: 1, status: :published)
      create(:lesson, course_module: published_module, title: hidden_lesson_title, position: 2, status: :draft)
      create(:lesson, course_module: hidden_module, title: private_lesson_title, position: 1, status: :published)

      get tenant_course_path(locale: locale, tenant_slug: tenant.slug, id: course.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(course_title)
      expect(response.body).to include(published_module_title)
      expect(response.body).to include(published_lesson_title)
      expect(response.body).not_to include(hidden_module_title)
      expect(response.body).not_to include(hidden_lesson_title)
      expect(response.body).not_to include(private_lesson_title)
    end

    it "returns not found for an unpublished course" do
      tenant = create(:tenant)
      course = create(:course, tenant: tenant, status: :draft)

      get tenant_course_path(locale: locale, tenant_slug: tenant.slug, id: course.slug)

      expect(response).to have_http_status(:not_found)
    end
  end
end
