class AdminTenants::BaseController < TenantsBaseController
  before_action :authenticate_user!
  before_action :ensure_member_of_current_tenant

  private

  def ensure_member_of_current_tenant
    return if current_user.is_super_admin?
    return if current_user.has_role_in_tenant?("platform_admin", current_tenant)

    redirect_to tenant_root_path(
      tenant_slug: current_tenant.slug,
      locale: I18n.locale
    ), alert: t("authorization.denied")
  end
end
