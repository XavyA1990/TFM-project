class AdminTenants::TenantsController < AdminTenants::BaseController
  before_action :set_tenant

  def show
    @tenant_details = AdminTenants::TenantsServices.new(:show, { tenant: @tenant }).call
    @tenant_non_customer_memberships = Admin::MembershipsServices.new(
      :for_tenant_without_customer,
      { tenant: @tenant }
    ).call
  end

  def edit
  end

  def update
    @tenant = AdminTenants::TenantsServices.new(
      :update,
      { tenant: @tenant, attributes: tenant_params }
    ).call

    if @tenant.errors.any?
      render :edit, status: :unprocessable_entity
    else
      redirect_to admin_tenants_tenant_path(tenant_slug: @tenant.slug)
    end
  end

  private

  def set_tenant
    @tenant = AdminTenants::TenantsServices.new(:get, { tenant: current_tenant }).call
  end

  def tenant_params
    params.require(:tenant).permit(:name, :description, :header_text, :subheader_text, :logo_url)
  end
end
