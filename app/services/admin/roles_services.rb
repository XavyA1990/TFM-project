module Admin
  class RolesServices
    def initialize(action, params, repository: RolesRepository)
      @action = action
      @params = params
      @repository = repository
    end

    def call
      return get_role if @action == :get
      return get_role_by_signed_id if @action == :get_by_signed_id
      return get_role_by_name if @action == :get_by_name
      return get_roles_available_for_assignment if @action == :available_for_assignment

      raise ArgumentError, I18n.t("services.errors.invalid_action")
    end

    private

    def get_role
      @repository.find(@params[:id])
    end

    def get_role_by_signed_id
      @repository.find_signed(@params[:signed_id], purpose: @params[:purpose])
    end

    def get_role_by_name
      @repository.find_by_name(@params[:name])
    end

    def get_roles_available_for_assignment
      @repository.all_ordered_except("super_admin")
    end
  end
end
