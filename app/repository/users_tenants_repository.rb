class UsersTenantsRepository
  def self.find_by_user_and_tenant(user:, tenant:)
    UsersTenant.find_by(user: user, tenant: tenant)
  end

  def self.find_or_create_by_user_and_tenant(user:, tenant:)
    UsersTenant.find_or_create_by!(user: user, tenant: tenant)
  end

  def self.for_user_with_tenants_and_roles(user)
    user.users_tenants.includes(:tenant, :roles)
  end

  def self.for_tenant_with_users_and_roles(tenant)
    tenant.users_tenants.includes(:user, :roles)
  end

  def self.destroy(membership)
    membership.destroy!
  end
end
