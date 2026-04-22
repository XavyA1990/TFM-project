class Users::RegistrationsController < Devise::RegistrationsController
  after_action :ensure_customer_membership, only: [:create], if: :resource_persisted?

  private

  def ensure_customer_membership
    return unless current_tenant.present?
    
    Users::EnsureCustomerMembership.call(user: resource, tenant: current_tenant)
  end

  def after_sign_up_path_for(resource)
    tenant = origin_tenant
    return super unless tenant.present?

    tenant_root_path(tenant_slug: tenant.slug)
  end

  def origin_tenant
    @origin_tenant ||= Tenant.friendly.find(cookies.signed[:origin_tenant_slug])
  end
end