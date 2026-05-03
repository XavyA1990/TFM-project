module Admin
  class MembershipsServices
    def initialize(action, params, repository: UsersTenantsRepository)
      @action = action
      @params = params
      @repository = repository
    end

    def call
      return get_memberships_for_user if @action == :for_user
      return get_memberships_for_user_in_tenant if @action == :for_user_in_tenant
      return get_role_management_panels if @action == :role_management_panels
      return get_non_customer_memberships_for_tenant if @action == :for_tenant_without_customer

      raise ArgumentError, I18n.t("services.errors.invalid_action")
    end

    private

    def get_memberships_for_user
      @repository.for_user_with_tenants_and_roles(@params[:user]).sort_by do |membership|
        membership.tenant.name.to_s.downcase
      end
    end

    def get_memberships_for_user_in_tenant
      @repository.for_user_with_tenants_and_roles(@params[:user]).select do |membership|
        membership.tenant_id == @params[:tenant].id
      end.sort_by do |membership|
        membership.tenant.name.to_s.downcase
      end
    end

    def get_role_management_panels
      memberships_by_tenant_id = @params[:memberships].index_by(&:tenant_id)

      @params[:tenants].map do |tenant|
        {
          tenant: tenant,
          membership: memberships_by_tenant_id[tenant.id],
        }
      end
    end

    def get_non_customer_memberships_for_tenant
      @repository.for_tenant_with_users_and_roles(@params[:tenant]).reject do |membership|
        membership.roles.any? { |role| role.name == "customer" }
      end.sort_by do |membership|
        membership.user.full_name.to_s.downcase
      end
    end
  end
end
