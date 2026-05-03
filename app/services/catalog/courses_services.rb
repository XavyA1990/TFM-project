module Catalog
  class CoursesServices
    PER_PAGE = 12
    FILTER_KEYS = %i[query sort].freeze
    SORT_OPTIONS = {
      "newest" => { column: :created_at, direction: :desc },
      "oldest" => { column: :created_at, direction: :asc },
      "title_asc" => { column: :title, direction: :asc },
      "title_desc" => { column: :title, direction: :desc }
    }.freeze

    def initialize(action, params = {}, repository: CoursesRepository)
      @action = action
      @params = params
      @repository = repository
      @tenant = params[:tenant]
    end

    def call
      return get_courses_for_index if @action == :index
      return get_course_for_show_page if @action == :show

      raise ArgumentError, "Invalid action"
    end

    private

    def get_courses_for_index
      filters = normalized_filters
      paginated_courses = PaginationService.new(
        relation: @repository.search_published_catalog_for_tenant(tenant: @tenant, filters: filters),
        page: @params[:page],
        per_page: PER_PAGE
      ).call

      {
        rows: paginated_courses[:rows].map { |course| serialize_course(course) },
        filters: filters,
        sort_filter_choices: available_sort_choices,
        current_page: paginated_courses[:current_page],
        per_page: paginated_courses[:per_page],
        total_count: paginated_courses[:total_count],
        total_pages: paginated_courses[:total_pages]
      }
    end

    def normalized_filters
      raw_filters = (@params[:filters] || {}).to_h.symbolize_keys.slice(*FILTER_KEYS)

      {
        query: raw_filters[:query].to_s.strip,
        sort: SORT_OPTIONS.key?(raw_filters[:sort].to_s) ? raw_filters[:sort].to_s : "newest"
      }
    end

    def available_sort_choices
      SORT_OPTIONS.keys.map do |sort_key|
        [I18n.t("courses.index.sort_options.#{sort_key}"), sort_key]
      end
    end

    def serialize_course(course)
      {
        slug: course.slug,
        title: course.title,
        short_description: course.short_description,
        description: course.description,
        cover_image_source: course.course_cover_image_source
      }
    end

    def get_course_for_show_page
      course = @repository.find_published_by_slug_in_tenant(@params[:slug], @tenant)
      published_modules = sorted_published_modules(course)

      {
        slug: course.slug,
        title: course.title,
        short_description: course.short_description,
        description: course.description,
        cover_image_source: course.course_cover_image_source,
        module_count: published_modules.size,
        lesson_count: published_modules.sum { |course_module| sorted_published_lessons(course_module).size },
        modules: published_modules.map do |course_module|
          published_lessons = sorted_published_lessons(course_module)

          {
            slug: course_module.slug,
            title: course_module.title,
            description: course_module.description,
            position: course_module.position,
            lesson_count: published_lessons.size,
            lessons: published_lessons.map do |lesson|
              {
                slug: lesson.slug,
                title: lesson.title,
                position: lesson.position
              }
            end
          }
        end
      }
    end

    def sorted_published_modules(course)
      course.course_modules.select(&:published?).sort_by(&:position)
    end

    def sorted_published_lessons(course_module)
      course_module.lessons.select(&:published?).sort_by(&:position)
    end
  end
end
