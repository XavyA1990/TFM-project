class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_super_admin_panel
  before_action :set_dashboard_sidebar_navigation

  private

  def authorize_super_admin_panel
    authorize! :access, :super_admin_panel
  end

  def set_dashboard_sidebar_navigation
    admin_tenant_links = Admin::TenantsServices.new(:get_all_by_name, {}).call.filter_map do |tenant|
      next unless current_ability.can?(:read, tenant)

      {
        label: tenant.name,
        path: admin_tenants_tenant_path(tenant_slug: tenant.slug),
        active: params[:tenant_slug] == tenant.slug,
        icon_image: tenant.logo_source,
      }
    end

    primary_links = []

    if current_ability.can?(:read, Tenant)
      primary_links << {
        label: t("admin.tenants.index.title"),
        path: admin_tenants_path,
        active: controller_path == "admin/tenants",
      }
    end

    if current_ability.can?(:read, User)
      primary_links << {
        label: t("admin.users.index.title"),
        path: admin_users_path,
        active: controller_path == "admin/users",
      }
    end

    if current_ability.can?(:read, Course)
      primary_links << {
        label: t("admin.courses.index.title"),
        path: admin_courses_path,
        active: controller_path == "admin/courses",
      }
    end

    @dashboard_sidebar = {
      title: t("navbar.admin"),
      home_path: admin_tenants_path,
      logo_source: nil,
      primary_links: primary_links,
      secondary_title: t("shared.dashboard_sidebar.admin_tenants"),
      secondary_links: admin_tenant_links,
    }
  end
end
