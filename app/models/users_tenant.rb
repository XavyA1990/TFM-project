class UsersTenant < ApplicationRecord
  belongs_to :user
  belongs_to :tenant
  
  has_many :user_tenant_roles, dependent: :destroy
  has_many :roles, through: :user_tenant_roles

  def roles
    user_tenant_roles.includes(:role).map(&:role)
  end

  def permissions
    Permission.joins(roles: :user_tenant_roles)
              .where(user_tenant_roles: { users_tenant_id: id })
              .distinct
  end
end