class TenantsBaseController < ApplicationController
  before_action :set_current_tenant

  helper_method :current_tenant

  private

  def set_current_tenant
    @current_tenant = Tenant.friendly.find(params[:tenant_slug])
    rescue ActiveRecord::RecordNotFound
      render file: "#{Rails.root}/public/404.html", status: :not_found, layout: true
  end

  def current_tenant
    @current_tenant
  end
end
