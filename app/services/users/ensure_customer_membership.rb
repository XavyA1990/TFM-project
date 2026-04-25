class Users::EnsureCustomerMembership
  def self.call(user:, tenant:)
    new(user: user, tenant: tenant).call
  end

  def initialize(
    user:,
    tenant:,
    users_tenants_repository: UsersTenantsRepository,
    user_tenant_roles_repository: UserTenantRolesRepository,
    roles_repository: RolesRepository
  )
    @user = user
    @tenant = tenant
    @users_tenants_repository = users_tenants_repository
    @user_tenant_roles_repository = user_tenant_roles_repository
    @roles_repository = roles_repository
  end

  def call
    return unless @user.present? && @tenant.present?

    existing_membership = @users_tenants_repository.find_by_user_and_tenant(
      user: @user,
      tenant: @tenant
    )
    return existing_membership if existing_membership.present?

    membership = @users_tenants_repository.find_or_create_by_user_and_tenant(
      user: @user,
      tenant: @tenant
    )
    customer_role = @roles_repository.find_by_name("customer")

    @user_tenant_roles_repository.create(
      users_tenant: membership,
      role: customer_role,
      scope_type: :selected_courses
    )

    membership
  end
end
