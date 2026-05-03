class Admin::TenantsController < Admin::BaseController
  before_action :set_tenant, only: %i[show edit update destroy]
  before_action :authorize_tenants_index!, only: %i[index]
  before_action :authorize_tenant_create!, only: %i[new create]
  before_action :authorize_tenant_read!, only: %i[show]
  before_action :authorize_tenant_update!, only: %i[edit update]
  before_action :authorize_tenant_destroy!, only: %i[destroy]

  def show
    tenant_service = Admin::TenantsServices.new(:show, { slug: params[:id] })
    @tenant_details = tenant_service.call
    @tenant_non_customer_memberships = Admin::MembershipsServices.new(
      :for_tenant_without_customer,
      { tenant: @tenant }
    ).call
  end

  def create
    @tenant = Tenant.new(tenant_attributes)
    prepared_logo = prepare_logo_asset(@tenant)

    if @tenant.errors.any?
      render :new, status: :unprocessable_entity
      return
    end

    Tenant.transaction do
      @tenant = Admin::TenantsServices.new(:create, tenant_attributes).call
      raise ActiveRecord::Rollback unless @tenant.persisted?

      attach_logo_asset(@tenant, prepared_logo)

      raise ActiveRecord::Rollback if @tenant.errors.any?
    end

    if @tenant.errors.any? || !@tenant.persisted?
      render :new, status: :unprocessable_entity
    else
      redirect_to admin_tenant_path(@tenant)
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
    prepared_logo = prepare_logo_asset(@tenant)

    if @tenant.errors.any?
      render :edit, status: :unprocessable_entity
      return
    end

    Tenant.transaction do
      @tenant = Admin::TenantsServices.new(:update, tenant_attributes.merge(slug: params[:id])).call
      raise ActiveRecord::Rollback if @tenant.errors.any?

      attach_logo_asset(@tenant, prepared_logo)

      raise ActiveRecord::Rollback if @tenant.errors.any?
    end

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

  def prepare_logo_asset(tenant)
    logo_blob_id = params.dig(:tenant, :logo_asset)
    return nil if logo_blob_id.blank?

    Tenants::AssetsServices.new(
      :prepare_logo,
      { tenant: tenant, signed_blob_id: logo_blob_id }
    ).call
  end

  def attach_logo_asset(tenant, prepared_logo)
    return if prepared_logo.blank?

    Tenants::AssetsServices.new(
      :attach_logo,
      { tenant: tenant, prepared_asset: prepared_logo }
    ).call
  end

  def tenant_attributes
    tenant_params.except(:logo_asset)
  end

  def tenant_params
    params.require(:tenant).permit(:name, :description, :header_text, :subheader_text, :logo_asset)
  end

  def authorize_tenants_index!
    authorize! :read, Tenant
  end

  def authorize_tenant_create!
    authorize! :create, Tenant
  end

  def authorize_tenant_read!
    authorize! :read, @tenant
  end

  def authorize_tenant_update!
    authorize! :update, @tenant
  end

  def authorize_tenant_destroy!
    authorize! :destroy, @tenant
  end
end
