class Role < ApplicationRecord
  has_many :user_tenant_roles
  has_many :users_tenants, through: :user_tenant_roles

  has_many :role_permissions
  has_many :permissions, through: :role_permissions

  validates :name, presence: true, uniqueness: true
  validates :description, length: { maximum: 255 }, allow_blank: true
end