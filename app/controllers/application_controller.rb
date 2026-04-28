class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :configure_permitted_parameters, if: :devise_controller?
  allow_browser versions: :modern
  around_action :switch_locale
  helper_method :ability_for, :dashboard_nav_links, :dashboard_sidebar_visible?, :tenant_context_present?, :current_tenant_for_ability

  rescue_from CanCan::AccessDenied do
    redirect_to root_path, alert: t("authorization.denied")
  end

  def current_ability
    ability_for(current_tenant_for_ability)
  end

  def ability_for(tenant = nil)
    @abilities_by_tenant ||= {}
    tenant_key = tenant&.id || :global

    @abilities_by_tenant[tenant_key] ||= Ability.new(current_user, tenant)
  end

  def dashboard_nav_links
    return [] unless user_signed_in?
    return [] if current_user.is_super_admin?

    current_user.dashboard_accessible_tenants.filter_map do |tenant|
      next unless ability_for(tenant).can?(:access_dashboard, tenant)

      {
        name: tenant.name,
        path: admin_tenants_tenant_path(tenant_slug: tenant.slug)
      }
    end
  end

  def current_tenant_for_ability
    return nil unless respond_to?(:current_tenant, true)

    current_tenant
  rescue ActiveRecord::RecordNotFound
    nil
  end


  def default_url_options
    { locale: I18n.locale }
  end

  def dashboard_sidebar_visible?
    controller_path.start_with?("admin/") || controller_path.start_with?("admin_tenants/")
  end

  def tenant_context_present?
    current_tenant_for_ability.present?
  end


  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :username, :first_name, :last_name, :avatar_url, :avatar_asset
    ])

    devise_parameter_sanitizer.permit(:account_update, keys: [
      :first_name, :last_name, :avatar_url, :avatar_asset
    ])
  end
end
