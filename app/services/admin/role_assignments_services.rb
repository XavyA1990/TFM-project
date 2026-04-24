module Admin
  class RoleAssignmentsServices
    SIGNED_ID_PURPOSE = :role_assignment

    def initialize(
      action,
      params,
      users_tenants_repository: UsersTenantsRepository,
      user_tenant_roles_repository: UserTenantRolesRepository
    )
      @action = action
      @params = params
      @users_tenants_repository = users_tenants_repository
      @user_tenant_roles_repository = user_tenant_roles_repository
    end

    def call
      return toggle if @action == :toggle

      raise ArgumentError, "Invalid action"
    end

    private

    def toggle
      user = Admin::UsersServices.new(:get, { slug: @params[:user_slug] }).call
      tenant = Admin::TenantsServices.new(
        :get_by_signed_id,
        { signed_id: @params[:tenant_token], purpose: SIGNED_ID_PURPOSE }
      ).call
      role = Admin::RolesServices.new(
        :get_by_signed_id,
        { signed_id: @params[:role_token], purpose: SIGNED_ID_PURPOSE }
      ).call
      membership = @users_tenants_repository.find_or_create_by_user_and_tenant(user: user, tenant: tenant)
      assignment = @user_tenant_roles_repository.find_by_users_tenant_and_role(users_tenant: membership, role: role)

      if assignment.present?
        return prevent_customer_removal(user, tenant, role) if customer_is_required?(membership, role)

        @user_tenant_roles_repository.destroy(assignment)

        return { status: :removed, user: user, tenant: tenant, role: role } if roles_left_for_membership?(membership)

        customer_role = Admin::RolesServices.new(:get_by_name, { name: "customer" }).call
        @user_tenant_roles_repository.create(
          users_tenant: membership,
          role: customer_role,
          scope_type: inferred_scope_type_for(customer_role)
        )

        return {
          status: :defaulted_to_customer,
          user: user,
          tenant: tenant,
          role: role,
          fallback_role: customer_role
        }
      end

      @user_tenant_roles_repository.create(
        users_tenant: membership,
        role: role,
        scope_type: inferred_scope_type_for(role)
      )

      { status: :added, user: user, tenant: tenant, role: role }
    end

    def inferred_scope_type_for(role)
      role.name == "customer" ? :selected_courses : :tenant
    end

    def roles_left_for_membership?(membership)
      @user_tenant_roles_repository.count_for_users_tenant(membership).positive?
    end

    def customer_is_required?(membership, role)
      role.name == "customer" && @user_tenant_roles_repository.count_for_users_tenant(membership) == 1
    end

    def prevent_customer_removal(user, tenant, role)
      { status: :customer_required, user: user, tenant: tenant, role: role }
    end
  end
end
