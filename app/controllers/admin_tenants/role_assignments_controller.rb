class AdminTenants::RoleAssignmentsController < AdminTenants::BaseController
  before_action :authorize_role_assignment!

  def create
    result = AdminTenants::RoleAssignmentsServices.new(
      :toggle,
      {
        user_slug: params[:user_id],
        tenant: current_tenant,
        role_token: role_assignment_params[:role_token]
      }
    ).call

    redirect_to admin_tenants_user_path(tenant_slug: current_tenant.slug, id: result[:user]), notice: notice_message_for(result)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    redirect_to admin_tenants_user_path(tenant_slug: current_tenant.slug, id: params[:user_id]), alert: e.message
  end

  private

  def role_assignment_params
    params.permit(:role_token)
  end

  def notice_message_for(result)
    case result[:status]
    when :removed
      t("admin_tenants.users.show.role_removed", role: result[:role].name, tenant: result[:tenant].name)
    when :defaulted_to_customer
      t(
        "admin_tenants.users.show.role_defaulted_to_customer",
        role: result[:role].name,
        tenant: result[:tenant].name,
        fallback_role: result[:fallback_role].name
      )
    when :customer_required
      t("admin_tenants.users.show.customer_role_required", tenant: result[:tenant].name)
    else
      t("admin_tenants.users.show.role_added", role: result[:role].name, tenant: result[:tenant].name)
    end
  end

  def authorize_role_assignment!
    authorize! :assign, Role
  end
end
