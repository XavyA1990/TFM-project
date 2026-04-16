class UsersTenant < ApplicationRecord
  belongs_to :user
  belongs_to :tenant

  def roles
    user_tenant_roles.includes(:role).map(&:role)
  end

  def permissions
    Permission.joins(roles: :user_tenant_roles)
              .where(user_tenant_roles: { users_tenant_id: id })
              .distinct
  end
end