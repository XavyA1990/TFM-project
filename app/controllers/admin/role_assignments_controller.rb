class Admin::RoleAssignmentsController < Admin::BaseController
  def create
    result = Admin::RoleAssignmentsServices.new(
      :toggle,
      {
        user_slug: params[:user_id],
        tenant_token: role_assignment_params[:tenant_token],
        role_token: role_assignment_params[:role_token]
      }
    ).call

    redirect_to admin_user_path(result[:user]), notice: notice_message_for(result)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    redirect_to admin_user_path(params[:user_id]), alert: e.message
  end

  private

  def role_assignment_params
    params.permit(:tenant_token, :role_token)
  end

  def notice_message_for(result)
    case result[:status]
    when :removed
      t("admin.users.show.role_removed", role: result[:role].name, tenant: result[:tenant].name)
    when :defaulted_to_customer
      t(
        "admin.users.show.role_defaulted_to_customer",
        role: result[:role].name,
        tenant: result[:tenant].name,
        fallback_role: result[:fallback_role].name
      )
    when :customer_required
      t("admin.users.show.customer_role_required", tenant: result[:tenant].name)
    else
      t("admin.users.show.role_added", role: result[:role].name, tenant: result[:tenant].name)
    end
  end
end
