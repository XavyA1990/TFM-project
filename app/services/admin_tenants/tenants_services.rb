module AdminTenants
  class TenantsServices
    def initialize(action, params, repository: TenantsRepository)
      @action = action
      @params = params
      @repository = repository
      @tenant = params[:tenant]
    end

    def call
      return get_tenant_for_show_page if @action == :show
      return get_tenant if @action == :get
      return update if @action == :update

      raise ArgumentError, "Invalid action"
    end

    private

    def get_tenant_for_show_page
      [
        [Tenant.human_attribute_name(:name), @tenant.name],
        [Tenant.human_attribute_name(:slug), @tenant.slug],
        [Tenant.human_attribute_name(:description), @tenant.description],
        [Tenant.human_attribute_name(:header_text), @tenant.header_text],
        [Tenant.human_attribute_name(:subheader_text), @tenant.subheader_text],
        [Tenant.human_attribute_name(:logo_asset), tenant_logo_value],
        [Tenant.human_attribute_name(:created_at), @tenant.created_at ? I18n.l(@tenant.created_at) : nil],
        [Tenant.human_attribute_name(:updated_at), @tenant.updated_at ? I18n.l(@tenant.updated_at) : nil]
      ]
    end

    def get_tenant
      @tenant
    end

    def update
      @repository.update(@tenant.id, @params[:attributes])
    end

    def tenant_logo_value
      return @tenant.logo_asset.filename.to_s if @tenant.logo_asset.attached?

      nil
    end
  end
end
