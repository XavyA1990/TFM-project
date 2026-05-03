class AdminTenants::TenantsController < AdminTenants::BaseController
  before_action :set_tenant
  before_action :authorize_tenant_read!, only: %i[show]
  before_action :authorize_tenant_update!, only: %i[edit update]

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
    prepared_logo = prepare_logo_asset(@tenant)

    if @tenant.errors.any?
      render :edit, status: :unprocessable_entity
      return
    end

    Tenant.transaction do
      @tenant = AdminTenants::TenantsServices.new(
        :update,
        { tenant: @tenant, attributes: tenant_attributes }
      ).call

      raise ActiveRecord::Rollback if @tenant.errors.any?

      attach_logo_asset(@tenant, prepared_logo)

      raise ActiveRecord::Rollback if @tenant.errors.any?
    end

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

  def authorize_tenant_read!
    authorize! :read, @tenant
  end

  def authorize_tenant_update!
    authorize! :update, @tenant
  end
end
