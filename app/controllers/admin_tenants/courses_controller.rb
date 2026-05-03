class AdminTenants::CoursesController < AdminTenants::BaseController
  before_action :set_course, only: %i[show edit update destroy]
  before_action :authorize_course_new!, only: %i[new create]
  before_action :authorize_courses_index!, only: %i[index]
  before_action :authorize_course_show!, only: %i[show]
  before_action :authorize_course_edit!, only: %i[edit update]
  before_action :authorize_course_destroy!, only: %i[destroy]

  def index
    courses_index_data = AdminTenants::CoursesServices.new(:index, { page: params[:page], tenant: current_tenant }).call

    @course_table_headers = [
      Course.human_attribute_name(:title),
      Course.human_attribute_name(:status),
      Course.human_attribute_name(:created_at),
      Course.human_attribute_name(:updated_at)
    ]
    @course_table_columns = Course.table_columns
    @courses = courses_index_data[:rows]
    @current_page = courses_index_data[:current_page]
    @per_page = courses_index_data[:per_page]
    @total_pages = courses_index_data[:total_pages]
    @total_count = courses_index_data[:total_count]
  end

  def new
    @course = AdminTenants::CoursesServices.new(:build, { tenant: current_tenant }).call
  end

  def create
    @course = AdminTenants::CoursesServices.new(:build, { tenant: current_tenant }).call
    prepared_cover_image = prepare_cover_image_asset(@course)

    if @course.errors.any?
      render :new, status: :unprocessable_entity
      return
    end

    Course.transaction do
      @course = AdminTenants::CoursesServices.new(
        :create,
        { tenant: current_tenant, attributes: course_attributes }
      ).call

      raise ActiveRecord::Rollback if @course.errors.any?

      attach_cover_image_asset(@course, prepared_cover_image)

      raise ActiveRecord::Rollback if @course.errors.any?
    end

    if @course.errors.any?
      render :new, status: :unprocessable_entity
    else
      redirect_to admin_tenants_course_path(tenant_slug: current_tenant.slug, id: @course.slug)
    end
  end

  def show
    course_show_data = AdminTenants::CoursesServices.new(:show, { slug: params[:id], tenant: current_tenant }).call
    @course_details = course_show_data[:details]
    @course_modules = course_show_data[:course_modules]
  end

  def edit
  end

  def update
    prepared_cover_image = prepare_cover_image_asset(@course)

    if @course.errors.any?
      render :edit, status: :unprocessable_entity
      return
    end

    Course.transaction do
      @course = AdminTenants::CoursesServices.new(
        :update,
        { course: @course, tenant: current_tenant, attributes: course_attributes }
      ).call

      raise ActiveRecord::Rollback if @course.errors.any?

      attach_cover_image_asset(@course, prepared_cover_image)

      raise ActiveRecord::Rollback if @course.errors.any?
    end

    if @course.errors.any?
      render :edit, status: :unprocessable_entity
    else
      redirect_to admin_tenants_course_path(tenant_slug: current_tenant.slug, id: @course.slug)
    end
  end

  def destroy
    AdminTenants::CoursesServices.new(:destroy, { course: @course, tenant: current_tenant }).call
    redirect_to admin_tenants_courses_path(tenant_slug: current_tenant.slug), notice: t("admin_tenants.courses.destroyed")
  end

  private

  def set_course
    @course = AdminTenants::CoursesServices.new(:get, { slug: params[:id], tenant: current_tenant }).call
  end

  def prepare_cover_image_asset(course)
    cover_image_blob_id = params.dig(:course, :course_cover_image_asset)
    return nil if cover_image_blob_id.blank?

    Courses::AssetsServices.new(
      :prepare_cover_image,
      { course: course, signed_blob_id: cover_image_blob_id }
    ).call
  end

  def attach_cover_image_asset(course, prepared_cover_image)
    return if prepared_cover_image.blank?

    Courses::AssetsServices.new(
      :attach_cover_image,
      { course: course, prepared_asset: prepared_cover_image }
    ).call
  end

  def course_attributes
    course_params.except(:course_cover_image_asset)
  end

  def course_params
    params.require(:course).permit(:title, :short_description, :description, :status, :course_cover_image_asset)
  end

  def authorize_courses_index!
    authorize! :read, Course
  end

  def authorize_course_new!
    authorize! :create, Course
  end

  def authorize_course_show!
    authorize! :read, @course
  end

  def authorize_course_edit!
    authorize! :update, @course
  end

  def authorize_course_destroy!
    authorize! :destroy, @course
  end
end
