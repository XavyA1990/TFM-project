module AdminTenants
  class RoleAssignmentsServices
    SIGNED_ID_PURPOSE = :role_assignment

    def initialize(action, params)
      @action = action
      @params = params
    end

    def call
      return toggle if @action == :toggle

      raise ArgumentError, "Invalid action"
    end

    private

    def toggle
      user = AdminTenants::UsersServices.new(:get, { slug: @params[:user_slug], tenant: @params[:tenant] }).call
      role = Admin::RolesServices.new(
        :get_by_signed_id,
        { signed_id: @params[:role_token], purpose: SIGNED_ID_PURPOSE }
      ).call

      RoleAssignments::ToggleService.new(
        user: user,
        tenant: @params[:tenant],
        role: role
      ).call
    end
  end
end
