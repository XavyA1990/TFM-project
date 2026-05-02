class AdminTenants::BaseController < TenantsBaseController
  before_action :authenticate_user!
  before_action :authorize_dashboard_access
  before_action :set_dashboard_sidebar_navigation

  private

  def authorize_dashboard_access
    authorize! :access_dashboard, current_tenant
  end

  def set_dashboard_sidebar_navigation
    secondary_links = [
      {
        label: t("tenants.show.title"),
        path: tenant_root_path(tenant_slug: current_tenant.slug),
        active: false,
      },
    ]

    if current_ability.can?(:access, :super_admin_panel)
      secondary_links.unshift(
        {
          label: t("shared.dashboard_sidebar.back_to_super_admin"),
          path: admin_tenants_path,
          active: controller_path.start_with?("admin/"),
        }
      )
    end

    primary_links = []

    if current_ability.can?(:read, current_tenant)
      primary_links << {
        label: t("admin_tenants.tenants.show.title"),
        path: admin_tenants_tenant_path(tenant_slug: current_tenant.slug),
        active: controller_path == "admin_tenants/tenants" && action_name == "show",
      }
    end

    if current_ability.can?(:read, User)
      primary_links << {
        label: t("admin_tenants.users.index.title"),
        path: admin_tenants_users_path(tenant_slug: current_tenant.slug),
        active: controller_path == "admin_tenants/users",
      }
    end

    if current_ability.can?(:read, Course)
      primary_links << {
        label: t("admin_tenants.courses.index.title"),
        path: admin_tenants_courses_path(tenant_slug: current_tenant.slug),
        active: controller_path == "admin_tenants/courses",
      }
    end

    if current_ability.can?(:update, current_tenant)
      primary_links << {
        label: t("admin_tenants.tenants.edit.title"),
        path: edit_admin_tenants_tenant_path(tenant_slug: current_tenant.slug),
        active: controller_path == "admin_tenants/tenants" && action_name == "edit",
      }
    end

    @dashboard_sidebar = {
      title: current_tenant.name,
      home_path: admin_tenants_tenant_path(tenant_slug: current_tenant.slug),
      logo_source: current_tenant.logo_source,
      primary_links: primary_links,
      secondary_title: t("shared.dashboard_sidebar.quick_links"),
      secondary_links: secondary_links,
    }
  end
end
