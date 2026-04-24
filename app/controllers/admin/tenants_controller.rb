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
    Admin::TenantsServices.new(:destroy, { slug: params[:id] }).call
    redirect_to admin_tenants_path, notice: I18n.t("admin.tenants.destroyed")
  end

  def index
    tenants_index_data = Admin::TenantsServices.new(:index, { page: params[:page] }).call

    @tenant_table_headers = [
      I18n.t("activerecord.attributes.tenant.name"),
      I18n.t("activerecord.attributes.tenant.slug"),
      I18n.t("activerecord.attributes.tenant.created_at"),
      I18n.t("activerecord.attributes.tenant.updated_at"),
    ]
    @tenant_table_columns = Tenant.table_columns
    @tenants = tenants_index_data[:rows]
    @current_page = tenants_index_data[:current_page]
    @per_page = tenants_index_data[:per_page]
    @total_pages = tenants_index_data[:total_pages]
    @total_count = tenants_index_data[:total_count]
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
