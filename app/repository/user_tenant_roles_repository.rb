class UserTenantRolesRepository
  def self.find_by_users_tenant_and_role(users_tenant:, role:)
    UserTenantRole.find_by(users_tenant: users_tenant, role: role)
  end

  def self.create(users_tenant:, role:, scope_type:)
    UserTenantRole.create!(
      users_tenant: users_tenant,
      role: role,
      scope_type: scope_type
    )
  end

  def self.for_users_tenant(users_tenant)
    users_tenant.user_tenant_roles
  end

  def self.count_for_users_tenant(users_tenant)
    users_tenant.user_tenant_roles.count
  end

  def self.destroy(assignment)
    assignment.destroy!
  end
end
