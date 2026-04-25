class AdminTenants::UsersController < AdminTenants::BaseController
  before_action :set_user, only: %i[show]

  def index
    users_index_data = AdminTenants::UsersServices.new(:index, { page: params[:page], tenant: current_tenant }).call

    @user_table_headers = [
      I18n.t("admin.users.index.full_name"),
      I18n.t("activerecord.attributes.user.email"),
      I18n.t("admin.users.index.tenant_role"),
      I18n.t("activerecord.attributes.user.created_at"),
      I18n.t("activerecord.attributes.user.updated_at"),
    ]
    @user_table_columns = User.table_columns
    @users = users_index_data[:rows]
    @current_page = users_index_data[:current_page]
    @per_page = users_index_data[:per_page]
    @total_pages = users_index_data[:total_pages]
    @total_count = users_index_data[:total_count]
  end

  def show
    @user_details = AdminTenants::UsersServices.new(:show, { slug: params[:id], tenant: current_tenant }).call
    @user_tenant_roles = Admin::MembershipsServices.new(:for_user_in_tenant, { user: @user, tenant: current_tenant }).call
    @available_roles = Admin::RolesServices.new(:available_for_assignment, {}).call
    @tenant_role_panels = Admin::MembershipsServices.new(
      :role_management_panels,
      { memberships: @user_tenant_roles, tenants: [current_tenant] }
    ).call
  end

  private

  def set_user
    @user = AdminTenants::UsersServices.new(:get, { slug: params[:id], tenant: current_tenant }).call
  end
end
