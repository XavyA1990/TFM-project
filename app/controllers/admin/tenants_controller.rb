class Admin::TenantsController < Admin::BaseController
  before_action :set_tenant, only: %i[show edit update destroy]

  def show
    tenant_service = Admin::TenantsServices.new(:show, { slug: params[:id] })
    @tenant_details = tenant_service.call
  end

  def create
    @tenant = Admin::TenantsServices.new(:create, tenant_params).call

    if @tenant.persisted?
      redirect_to admin_tenant_path(@tenant)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
  end

  def index
    @tenant_table_headers = [
      I18n.t("activerecord.attributes.tenant.name"),
      I18n.t("activerecord.attributes.tenant.slug"),
      I18n.t("activerecord.attributes.tenant.created_at"),
      I18n.t("activerecord.attributes.tenant.updated_at"),
    ]
    @tenant_table_columns = Tenant.table_columns
    @tenants = Admin::TenantsServices.new(:index, {}).call
  end

  def update
    @tenant = Admin::TenantsServices.new(:update, tenant_params.merge(slug: params[:id])).call

    if @tenant.errors.any?
      render :edit, status: :unprocessable_entity
    else
      redirect_to admin_tenant_path(@tenant)
    end
  end

  def new
    @tenant = Tenant.new
  end

  def edit
  end

  private

  def set_tenant
    @tenant = Admin::TenantsServices.new(:get, { slug: params[:id] }).call
  end

  def tenant_params
    params.require(:tenant).permit(:name, :description, :header_text, :subheader_text, :logo_url)
  end
end
