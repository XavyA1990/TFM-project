class CoursesRepository
  def self.all_for_tenant(tenant)
    Course.where(tenant: tenant).order(created_at: :desc)
  end
end
