class Users::SessionsController < Devise::SessionsController
  private

  def after_sign_in_path_for(resource)
    tenant = origin_tenant
    return root_path unless tenant.present?

    tenant_root_path(tenant_slug: tenant.slug)
  end

  def origin_tenant
    slug = cookies.signed[:origin_tenant_slug]
    return nil unless slug.present?

    Tenant.friendly.find(slug)
  end
end