class AdminTenants::CourseModulesController < AdminTenants::BaseController
  before_action :set_course
  before_action :set_course_module, only: %i[edit update destroy]
  before_action :authorize_course_module_create!, only: %i[new create]
  before_action :authorize_course_module_update!, only: %i[edit update]
  before_action :authorize_course_module_destroy!, only: %i[destroy]

  def new
    @course_module = AdminTenants::CourseModulesServices.new(
      :build,
      { course: @course }
    ).call
  end

  def create
    @course_module = AdminTenants::CourseModulesServices.new(
      :build,
      { course: @course, attributes: course_module_attributes }
    ).call
    prepared_cover_image = prepare_cover_image_asset(@course_module)

    if @course_module.errors.any?
      render :new, status: :unprocessable_entity
      return
    end

    CourseModule.transaction do
      @course_module = AdminTenants::CourseModulesServices.new(
        :create,
        { course: @course, attributes: course_module_attributes }
      ).call

      raise ActiveRecord::Rollback if @course_module.errors.any?

      attach_cover_image_asset(@course_module, prepared_cover_image)

      raise ActiveRecord::Rollback if @course_module.errors.any?
    end

    if @course_module.errors.any?
      render :new, status: :unprocessable_entity
    else
      redirect_to admin_tenants_course_path(tenant_slug: current_tenant.slug, id: @course.slug)
    end
  end

  def edit
  end

  def update
    prepared_cover_image = prepare_cover_image_asset(@course_module)

    if @course_module.errors.any?
      render :edit, status: :unprocessable_entity
      return
    end

    CourseModule.transaction do
      @course_module = AdminTenants::CourseModulesServices.new(
        :update,
        { course: @course, course_module: @course_module, attributes: course_module_attributes }
      ).call

      raise ActiveRecord::Rollback if @course_module.errors.any?

      attach_cover_image_asset(@course_module, prepared_cover_image)

      raise ActiveRecord::Rollback if @course_module.errors.any?
    end

    if @course_module.errors.any?
      render :edit, status: :unprocessable_entity
    else
      redirect_to admin_tenants_course_path(tenant_slug: current_tenant.slug, id: @course.slug)
    end
  end

  def destroy
    AdminTenants::CourseModulesServices.new(
      :destroy,
      { course: @course, course_module: @course_module }
    ).call

    redirect_to admin_tenants_course_path(tenant_slug: current_tenant.slug, id: @course.slug), notice: t("admin_tenants.course_modules.destroyed")
  end

  private

  def set_course
    @course = AdminTenants::CoursesServices.new(:get, { slug: params[:course_id], tenant: current_tenant }).call
  end

  def set_course_module
    @course_module = AdminTenants::CourseModulesServices.new(
      :get,
      { course: @course, slug: params[:id] }
    ).call
  end

  def prepare_cover_image_asset(course_module)
    cover_image_blob_id = params.dig(:course_module, :module_cover_image_asset)
    return nil if cover_image_blob_id.blank?

    CourseModules::AssetsServices.new(
      :prepare_cover_image,
      { course_module: course_module, signed_blob_id: cover_image_blob_id }
    ).call
  end

  def attach_cover_image_asset(course_module, prepared_cover_image)
    return if prepared_cover_image.blank?

    CourseModules::AssetsServices.new(
      :attach_cover_image,
      { course_module: course_module, prepared_asset: prepared_cover_image }
    ).call
  end

  def course_module_attributes
    course_module_params.except(:module_cover_image_asset)
  end

  def course_module_params
    params.require(:course_module).permit(:title, :description, :position, :status, :module_cover_image_asset)
  end

  def authorize_course_module_create!
    authorize! :create, @course
  end

  def authorize_course_module_update!
    authorize! :update, @course
  end

  def authorize_course_module_destroy!
    authorize! :destroy, @course
  end
end
