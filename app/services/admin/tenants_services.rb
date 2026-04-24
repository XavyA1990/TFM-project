module Admin
  class TenantsServices
    PER_PAGE = 15

    attr_reader :tenant

    def initialize(action, params, repository: TenantsRepository)
      @tenant = repository.find_by_slug(params[:slug]) if params[:slug].present?
      @action = action
      @params = params
      @repository = repository
    end

    def call
      return get_tenants_for_index if @action == :index
      return get_tenant_for_show_page if @action == :show
      return get_tenant if @action == :get
      return create if @action == :create
      return update if @action == :update
      return destroy if @action == :destroy

      raise ArgumentError, "Invalid action"
    end

    private

    def create
      @repository.create(@params)
    end

    def update
      @repository.update(@tenant.id, @params)
    end

    def destroy
      @repository.destroy(@tenant.id)
    end

    def get_tenants_for_index
      PaginationService.new(
        relation: @repository.all_ordered,
        page: @params[:page],
        per_page: PER_PAGE
      ).call
    end

    def get_tenant
      @tenant
    end

    def get_tenant_for_show_page
      [
        [Tenant.human_attribute_name(:name), @tenant.name],
        [Tenant.human_attribute_name(:slug), @tenant.slug],
        [Tenant.human_attribute_name(:description), @tenant.description],
        [Tenant.human_attribute_name(:header_text), @tenant.header_text],
        [Tenant.human_attribute_name(:subheader_text), @tenant.subheader_text],
        [Tenant.human_attribute_name(:logo_url), @tenant.logo_url],
        [Tenant.human_attribute_name(:created_at), @tenant.created_at ? I18n.l(@tenant.created_at) : nil],
        [Tenant.human_attribute_name(:updated_at), @tenant.updated_at ? I18n.l(@tenant.updated_at) : nil]
      ]
    end
  end
end
