class TenantsController < TenantsBaseController
  def show
    @published_courses = Tenants::CoursesServices.new(
      :published_showcase,
      { tenant: current_tenant }
    ).call
  end
end
