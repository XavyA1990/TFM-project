class Users::SessionsController < Devise::SessionsController
  before_action :ensure_origin_tenant_present!, only: %i[new create]

  private

  def after_sign_in_path_for(resource)
    tenant = origin_tenant
    return root_path unless tenant.present?

    Users::EnsureCustomerMembership.call(user: resource, tenant: tenant)

    tenant_root_path(tenant_slug: tenant.slug)
  end

  def origin_tenant
    slug = cookies.signed[:origin_tenant_slug]
    return nil unless slug.present?

    Tenant.friendly.find(slug)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def ensure_origin_tenant_present!
    return if origin_tenant.present?

    redirect_to root_path, alert: t("authorization.login_from_tenant_required")
  end
end
