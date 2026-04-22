class TenantsBaseController < ApplicationController
  before_action :set_current_tenant
  before_action :store_origin_tenant

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

  def store_origin_tenant
    return if !current_tenant.present? || current_tenant.slug == cookies.signed[:origin_tenant_slug]

    cookies.signed[:origin_tenant_slug] = {
      value: current_tenant.slug,
      expires: 1.hour.from_now,
      httponly: true,
      same_site: :strict
    }
  end
end
