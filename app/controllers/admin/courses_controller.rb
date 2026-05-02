class Admin::CoursesController < Admin::BaseController
  before_action :authorize_courses_index!, only: %i[index]

  def index
    courses_index_data = Admin::CoursesServices.new(:index, { page: params[:page] }).call

    @course_table_headers = [
      Course.human_attribute_name(:title),
      I18n.t("admin.courses.index.tenant"),
      Course.human_attribute_name(:status),
      Course.human_attribute_name(:created_at),
      Course.human_attribute_name(:updated_at)
    ]
    @course_table_columns = %i[title tenant_name status created_at updated_at]
    @courses = courses_index_data[:rows]
    @current_page = courses_index_data[:current_page]
    @per_page = courses_index_data[:per_page]
    @total_pages = courses_index_data[:total_pages]
    @total_count = courses_index_data[:total_count]
  end

  private

  def authorize_courses_index!
    authorize! :read, Course
  end
end
