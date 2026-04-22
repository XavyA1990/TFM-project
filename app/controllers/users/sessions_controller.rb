class Users::SessionsController < Devise::SessionsController
  private

  def after_sign_in_path_for(resource)
    tenant = origin_tenant
    return super unless tenant.present?

    tenant_root_path(tenant_slug: tenant.slug)
  end

  def origin_tenant
    @origin_tenant ||= Tenant.friendly.find(cookies.signed[:origin_tenant_slug])
  end
end