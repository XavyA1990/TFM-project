module Home
  class TenantsServices
    def initialize(action, params = {}, repository: TenantsRepository)
      @action = action
      @params = params
      @repository = repository
    end

    def call
      return tenants_for_home if @action == :index

      raise ArgumentError, "Invalid action"
    end

    private

    def tenants_for_home
      @repository.all_ordered_by_name
    end
  end
end
