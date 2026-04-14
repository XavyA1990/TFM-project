class UserTenantRole < ApplicationRecord
  belongs_to :users_tenant
  belongs_to :role

  enum :scope_type, {
    selected_courses: "selected_courses",
    tenant: "tenant"
  }
end