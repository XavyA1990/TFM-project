class AdminTenants::LessonsController < AdminTenants::BaseController
  before_action :set_course
  before_action :set_course_module
  before_action :set_lesson, only: %i[edit update destroy]
  before_action :authorize_lesson_create!, only: %i[new create]
  before_action :authorize_lesson_update!, only: %i[edit update]
  before_action :authorize_lesson_destroy!, only: %i[destroy]

  def new
    @lesson = AdminTenants::LessonsServices.new(
      :build,
      { course_module: @course_module }
    ).call
  end

  def create
    @lesson = AdminTenants::LessonsServices.new(
      :build,
      { course_module: @course_module, attributes: lesson_attributes }
    ).call
    prepared_content = prepare_content_asset(@lesson)
    validate_content_requirements(@lesson, prepared_content)

    if @lesson.errors.any?
      render :new, status: :unprocessable_entity
      return
    end

    Lesson.transaction do
      @lesson = AdminTenants::LessonsServices.new(
        :create,
        { course_module: @course_module, attributes: lesson_attributes }
      ).call

      raise ActiveRecord::Rollback if @lesson.errors.any?

      sync_content_asset(@lesson, prepared_content)

      raise ActiveRecord::Rollback if @lesson.errors.any?
    end

    if @lesson.errors.any?
      render :new, status: :unprocessable_entity
    else
      redirect_to admin_tenants_course_path(tenant_slug: current_tenant.slug, id: @course.slug)
    end
  end

  def edit
  end

  def update
    @lesson.assign_attributes(lesson_attributes)
    prepared_content = prepare_content_asset(@lesson)
    validate_content_requirements(@lesson, prepared_content)

    if @lesson.errors.any?
      render :edit, status: :unprocessable_entity
      return
    end

    Lesson.transaction do
      @lesson = AdminTenants::LessonsServices.new(
        :update,
        { course_module: @course_module, lesson: @lesson, attributes: lesson_attributes }
      ).call

      raise ActiveRecord::Rollback if @lesson.errors.any?

      sync_content_asset(@lesson, prepared_content)

      raise ActiveRecord::Rollback if @lesson.errors.any?
    end

    if @lesson.errors.any?
      render :edit, status: :unprocessable_entity
    else
      redirect_to admin_tenants_course_path(tenant_slug: current_tenant.slug, id: @course.slug)
    end
  end

  def destroy
    AdminTenants::LessonsServices.new(
      :destroy,
      { course_module: @course_module, lesson: @lesson }
    ).call

    redirect_to admin_tenants_course_path(tenant_slug: current_tenant.slug, id: @course.slug), notice: t("admin_tenants.lessons.destroyed")
  end

  private

  def set_course
    @course = AdminTenants::CoursesServices.new(:get, { slug: params[:course_id], tenant: current_tenant }).call
  end

  def set_course_module
    @course_module = AdminTenants::CourseModulesServices.new(
      :get,
      { course: @course, slug: params[:course_module_id] }
    ).call
  end

  def set_lesson
    @lesson = AdminTenants::LessonsServices.new(
      :get,
      { course_module: @course_module, slug: params[:id] }
    ).call
  end

  def prepare_content_asset(lesson)
    content_blob_id = params.dig(:lesson, :lesson_content_asset)
    return nil if content_blob_id.blank?

    Lessons::AssetsServices.new(
      :prepare_content,
      { lesson: lesson, signed_blob_id: content_blob_id }
    ).call
  end

  def attach_content_asset(lesson, prepared_content)
    return if prepared_content.blank?

    Lessons::AssetsServices.new(
      :attach_content,
      { lesson: lesson, prepared_asset: prepared_content }
    ).call
  end

  def purge_content_asset(lesson)
    Lessons::AssetsServices.new(
      :purge_content,
      { lesson: lesson }
    ).call
  end

  def sync_content_asset(lesson, prepared_content)
    return purge_content_asset(lesson) if lesson.text?

    attach_content_asset(lesson, prepared_content)
  end

  def validate_content_requirements(lesson, prepared_content)
    return if lesson.text?
    return if prepared_content.present?

    if lesson.lesson_content_asset.attached?
      return if lesson.content_type_allowed_for_lesson_type?(lesson.lesson_content_asset.blob.content_type)

      lesson.errors.add(
        :lesson_content_asset,
        I18n.t("activerecord.errors.models.lesson.attributes.lesson_content_asset.invalid_for_type")
      )
      return
    end

    lesson.errors.add(
      :lesson_content_asset,
      I18n.t("activerecord.errors.models.lesson.attributes.lesson_content_asset.required_for_type")
    )
  end

  def lesson_attributes
    lesson_params.except(:lesson_content_asset)
  end

  def lesson_params
    params.require(:lesson).permit(:title, :description, :body, :position, :lesson_type, :status, :lesson_content_asset)
  end

  def authorize_lesson_create!
    authorize! :create, @course
  end

  def authorize_lesson_update!
    authorize! :update, @course
  end

  def authorize_lesson_destroy!
    authorize! :destroy, @course
  end
end
