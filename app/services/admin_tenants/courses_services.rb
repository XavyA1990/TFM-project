module AdminTenants
  class CoursesServices
    PER_PAGE = 15

    def initialize(action, params, repository: CoursesRepository)
      @action = action
      @params = params
      @repository = repository
      @tenant = params[:tenant]
    end

    def call
      return get_courses_for_index if @action == :index

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
  end
end
