class CoursesController < TenantsBaseController
  def index
    courses_index_data = Catalog::CoursesServices.new(
      :index,
      { page: params[:page], filters: sort_params, tenant: current_tenant }
    ).call

    @courses = courses_index_data[:rows]
    @filters = courses_index_data[:filters]
    @sort_filter_choices = courses_index_data[:sort_filter_choices]
    @current_page = courses_index_data[:current_page]
    @per_page = courses_index_data[:per_page]
    @total_pages = courses_index_data[:total_pages]
    @total_count = courses_index_data[:total_count]
  end

  private

  def sort_params
    params.fetch(:filters, {}).permit(:query, :sort)
  end
end
