class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[show]
  def index
    users_index_data = Admin::UsersServices.new(:index, { page: params[:page] }).call

    @user_table_headers = [
      I18n.t("admin.users.index.full_name"),
      I18n.t("activerecord.attributes.user.email"),
      I18n.t("admin.users.index.tenant_role"),
      I18n.t("activerecord.attributes.user.created_at"),
      I18n.t("activerecord.attributes.user.updated_at"),
    ]

    @user_table_columns = %i[full_name email tenant_role created_at updated_at]
    @users = users_index_data[:rows]
    @current_page = users_index_data[:current_page]
    @per_page = users_index_data[:per_page]
    @total_pages = users_index_data[:total_pages]
    @total_count = users_index_data[:total_count]
  end

  def show
  end

  private

  def set_user
    @user = Admin::UsersServices.new(:get, { slug: params[:id] }).call
  end
end
