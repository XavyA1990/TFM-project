module RoleAssignments
  class ToggleService
    def initialize(user:, tenant:, role:, users_tenants_repository: UsersTenantsRepository, user_tenant_roles_repository: UserTenantRolesRepository)
      @user = user
      @tenant = tenant
      @role = role
      @users_tenants_repository = users_tenants_repository
      @user_tenant_roles_repository = user_tenant_roles_repository
    end

    def call
      membership = @users_tenants_repository.find_or_create_by_user_and_tenant(user: @user, tenant: @tenant)
      assignment = @user_tenant_roles_repository.find_by_users_tenant_and_role(users_tenant: membership, role: @role)

      if assignment.present?
        return prevent_customer_removal if customer_is_required?(membership)

        @user_tenant_roles_repository.destroy(assignment)
        return removed_result if roles_left_for_membership?(membership)

        customer_role = Admin::RolesServices.new(:get_by_name, { name: "customer" }).call
        @user_tenant_roles_repository.create(
          users_tenant: membership,
          role: customer_role,
          scope_type: inferred_scope_type_for(customer_role)
        )

        return defaulted_result(customer_role)
      end

      @user_tenant_roles_repository.create(
        users_tenant: membership,
        role: @role,
        scope_type: inferred_scope_type_for(@role)
      )

      added_result
    end

    private

    def inferred_scope_type_for(role)
      role.name == "customer" ? :selected_courses : :tenant
    end

    def roles_left_for_membership?(membership)
      @user_tenant_roles_repository.count_for_users_tenant(membership).positive?
    end

    def customer_is_required?(membership)
      @role.name == "customer" && @user_tenant_roles_repository.count_for_users_tenant(membership) == 1
    end

    def added_result
      { status: :added, user: @user, tenant: @tenant, role: @role }
    end

    def removed_result
      { status: :removed, user: @user, tenant: @tenant, role: @role }
    end

    def defaulted_result(customer_role)
      {
        status: :defaulted_to_customer,
        user: @user,
        tenant: @tenant,
        role: @role,
        fallback_role: customer_role
      }
    end

    def prevent_customer_removal
      { status: :customer_required, user: @user, tenant: @tenant, role: @role }
    end
  end
end
