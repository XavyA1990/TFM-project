class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_super_admin_status
  before_action :set_dashboard_sidebar_navigation

  private

  def validate_super_admin_status
    redirect_to root_path, alert: t("authorization.denied") unless current_user.is_super_admin?
  end

  def set_dashboard_sidebar_navigation
    admin_tenant_links = Admin::TenantsServices.new(:get_all_by_name, {}).call.map do |tenant|
      {
        label: tenant.name,
        path: admin_tenants_tenant_path(tenant_slug: tenant.slug),
        active: params[:tenant_slug] == tenant.slug,
      }
    end

    @dashboard_sidebar = {
      title: t("navbar.admin"),
      home_path: admin_tenants_path,
      primary_links: [
        {
          label: t("admin.tenants.index.title"),
          path: admin_tenants_path,
          active: controller_path == "admin/tenants",
        },
        {
          label: t("admin.users.index.title"),
          path: admin_users_path,
          active: controller_path == "admin/users",
        },
      ],
      secondary_title: t("shared.dashboard_sidebar.admin_tenants"),
      secondary_links: admin_tenant_links,
    }
  end
end
