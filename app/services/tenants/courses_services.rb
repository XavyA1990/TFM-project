module Tenants
  class CoursesServices
    SHOWCASE_LIMIT = 5

    def initialize(action, params = {}, repository: CoursesRepository)
      @action = action
      @params = params
      @repository = repository
      @tenant = params[:tenant]
    end

    def call
      return published_showcase_courses if @action == :published_showcase

      raise ArgumentError, "Invalid action"
    end

    private

    def published_showcase_courses
      @repository.latest_published_for_tenant(@tenant, limit: SHOWCASE_LIMIT).map do |course|
        {
          slug: course.slug,
          title: course.title,
          short_description: course.short_description,
          description: course.description,
          cover_image_source: course.course_cover_image_source
        }
      end
    end
  end
end
