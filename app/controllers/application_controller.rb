class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :configure_permitted_parameters, if: :devise_controller?
  allow_browser versions: :modern
  around_action :switch_locale
  helper_method :dashboard_sidebar_visible?, :tenant_context_present?

  rescue_from CanCan::AccessDenied do
    redirect_to root_path, alert: t("authorization.denied")
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, current_tenant_for_ability)
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
      :username, :first_name, :last_name, :avatar_url
    ])

    devise_parameter_sanitizer.permit(:account_update, keys: [
      :username, :first_name, :last_name, :avatar_url
    ])
  end
end
