module AdminTenants
  class CoursesServices
    PER_PAGE = 15

    def initialize(action, params, repository: CoursesRepository)
      @action = action
      @params = params
      @repository = repository
      @tenant = params[:tenant]
      @course = repository.find_by_slug_in_tenant(params[:slug], @tenant) if params[:slug].present?
    end

    def call
      return get_courses_for_index if @action == :index
      return get_course_for_show_page if @action == :show
      return get_course if @action == :get

      raise ArgumentError, "Invalid action"
    end

    private

    def get_courses_for_index
      paginated_courses = PaginationService.new(
        relation: @repository.all_for_tenant(@tenant),
        page: @params[:page],
        per_page: PER_PAGE
      ).call

      {
        rows: paginated_courses[:rows].map do |course|
          {
            slug: course.slug,
            title: course.title,
            status: course.status.humanize,
            created_at: I18n.l(course.created_at),
            updated_at: I18n.l(course.updated_at)
          }
        end,
        current_page: paginated_courses[:current_page],
        per_page: paginated_courses[:per_page],
        total_count: paginated_courses[:total_count],
        total_pages: paginated_courses[:total_pages]
      }
    end

    def get_course_for_show_page
      {
        details: [
          [Course.human_attribute_name(:title), @course.title],
          [Course.human_attribute_name(:short_description), @course.short_description],
          [Course.human_attribute_name(:description), @course.description],
          [Course.human_attribute_name(:status), @course.status.humanize],
          [I18n.t("admin_tenants.courses.show.module_count"), sorted_modules.size],
          [I18n.t("admin_tenants.courses.show.lesson_count"), sorted_modules.sum { |course_module| course_module.lessons.size }],
          [Course.human_attribute_name(:created_at), @course.created_at ? I18n.l(@course.created_at) : nil],
          [Course.human_attribute_name(:updated_at), @course.updated_at ? I18n.l(@course.updated_at) : nil]
        ],
        course_modules: sorted_modules.map do |course_module|
          {
            title: course_module.title,
            description: course_module.description,
            status: course_module.status.humanize,
            position: course_module.position,
            created_at: course_module.created_at ? I18n.l(course_module.created_at) : nil,
            updated_at: course_module.updated_at ? I18n.l(course_module.updated_at) : nil,
            lessons: sorted_lessons(course_module).map do |lesson|
              {
                title: lesson.title,
                description: lesson.description,
                body: lesson.body,
                lesson_type: lesson.lesson_type.humanize,
                status: lesson.status.humanize,
                position: lesson.position,
                content_reference: lesson.body.present? ? I18n.t("admin_tenants.courses.show.text_content_available") : lesson.content_url,
                created_at: lesson.created_at ? I18n.l(lesson.created_at) : nil,
                updated_at: lesson.updated_at ? I18n.l(lesson.updated_at) : nil
              }
            end
          }
        end
      }
    end

    def get_course
      @course
    end

    def sorted_modules
      @course.course_modules.sort_by(&:position)
    end

    def sorted_lessons(course_module)
      course_module.lessons.sort_by(&:position)
    end
  end
end
