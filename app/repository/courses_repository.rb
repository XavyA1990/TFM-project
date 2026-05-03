class CoursesRepository

  SORT_COLUMN_MAP = {
    "newest" => :created_at,
    "oldest" => :created_at,
    "title_asc" => :title,
    "title_desc" => :title
  }.freeze

  SORT_DIRECTION_MAP = {
    "newest" => :desc,
    "oldest" => :asc,
    "title_asc" => :asc,
    "title_desc" => :desc
  }.freeze
  
  def self.search_published_catalog_for_tenant(tenant:, filters:)
    relation = Course.includes(:tenant, course_cover_image_asset_attachment: :blob)
      .where(tenant: tenant, status: :published)

    if filters[:query].present?
      search_term = "%#{ActiveRecord::Base.sanitize_sql_like(filters[:query])}%"
      relation = relation.where(
        "courses.title ILIKE :term OR courses.short_description ILIKE :term OR courses.description ILIKE :term",
        term: search_term
      )
    end

    sort_option = filters[:sort].to_s
    sort_column = %w[created_at title].include?(SORT_COLUMN_MAP.fetch(sort_option, :created_at).to_s) ? SORT_COLUMN_MAP.fetch(sort_option, :created_at) : :created_at
    sort_direction = SORT_DIRECTION_MAP.fetch(sort_option, :desc)

    relation.distinct.order(sort_column => sort_direction)
  end

  def self.latest_published_for_tenant(tenant, limit:)
    Course.includes(course_cover_image_asset_attachment: :blob)
      .where(tenant: tenant, status: :published)
      .order(created_at: :desc)
      .limit(limit)
  end

  def self.all_with_tenant
    Course.includes(:tenant).order(created_at: :desc)
  end

  def self.all_for_tenant(tenant)
    Course.where(tenant: tenant).order(created_at: :desc)
  end

  def self.find_by_slug_in_tenant(slug, tenant)
    Course.where(tenant: tenant)
      .includes(course_modules: :lessons)
      .friendly
      .find(slug)
  end

  def self.find_published_by_slug_in_tenant(slug, tenant)
    Course.where(tenant: tenant, status: :published)
      .includes(
        course_cover_image_asset_attachment: :blob,
        course_modules: :lessons
      )
      .friendly
      .find(slug)
  end

  def self.create(params)
    Course.create(params)
  end

  def self.update(course, params)
    course.update(params)
    course
  end

  def self.destroy(course)
    course.destroy
  end
end
