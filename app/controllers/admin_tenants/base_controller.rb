class AdminTenants::BaseController < TenantsBaseController
  before_action :authenticate_user!
  before_action :ensure_member_of_current_tenant
  before_action :set_dashboard_sidebar_navigation

  private

  def ensure_member_of_current_tenant
    return if current_user.is_super_admin?
    return if current_user.has_role_in_tenant?("platform_admin", current_tenant)

    redirect_to tenant_root_path(
      tenant_slug: current_tenant.slug,
      locale: I18n.locale
    ), alert: t("authorization.denied")
  end

  def set_dashboard_sidebar_navigation
    secondary_links = [
      {
        label: t("tenants.show.title"),
        path: tenant_root_path(tenant_slug: current_tenant.slug),
        active: false,
      },
    ]

    if current_user.is_super_admin?
      secondary_links.unshift(
        {
          label: t("shared.dashboard_sidebar.back_to_super_admin"),
          path: admin_tenants_path,
          active: controller_path.start_with?("admin/"),
        }
      )
    end

    @dashboard_sidebar = {
      title: current_tenant.name,
      home_path: admin_tenants_tenant_path(tenant_slug: current_tenant.slug),
      primary_links: [
        {
          label: t("admin_tenants.tenants.show.title"),
          path: admin_tenants_tenant_path(tenant_slug: current_tenant.slug),
          active: controller_path == "admin_tenants/tenants" && action_name == "show",
        },
        {
          label: t("admin_tenants.users.index.title"),
          path: admin_tenants_users_path(tenant_slug: current_tenant.slug),
          active: controller_path == "admin_tenants/users",
        },
        {
          label: t("admin_tenants.tenants.edit.title"),
          path: edit_admin_tenants_tenant_path(tenant_slug: current_tenant.slug),
          active: controller_path == "admin_tenants/tenants" && action_name == "edit",
        },
      ],
      secondary_title: t("shared.dashboard_sidebar.quick_links"),
      secondary_links: secondary_links,
    }
  end
end
