class CoursesRepository
  def self.all_for_tenant(tenant)
    Course.where(tenant: tenant).order(created_at: :desc)
  end

  def self.find_by_slug_in_tenant(slug, tenant)
    Course.where(tenant: tenant)
      .includes(course_modules: :lessons)
      .friendly
      .find(slug)
  end
end
