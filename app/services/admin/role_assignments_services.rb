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

      raise ArgumentError, I18n.t("services.errors.invalid_action")
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
      RoleAssignments::ToggleService.new(
        user: user,
        tenant: tenant,
        role: role,
        users_tenants_repository: @users_tenants_repository,
        user_tenant_roles_repository: @user_tenant_roles_repository
      ).call
    end
  end
end
