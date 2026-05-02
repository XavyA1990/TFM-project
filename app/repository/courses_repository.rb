class CoursesRepository
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
