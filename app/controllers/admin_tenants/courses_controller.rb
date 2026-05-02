class AdminTenants::CoursesController < AdminTenants::BaseController
  before_action :authorize_courses_index!, only: %i[index]

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

  private

  def authorize_courses_index!
    authorize! :read, Course
  end
end
