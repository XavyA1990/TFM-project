FactoryBot.define do
  factory :user_tenant_role do
    users_tenant
    role
    scope_type { :selected_courses }
  end
end
