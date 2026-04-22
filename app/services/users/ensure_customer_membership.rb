class Users::EnsureCustomerMembership
  def self.call(user:, tenant:)
    return unless user.present? && tenant.present?

    membership = UsersTenant.find_or_create_by(user: user, tenant: tenant)
    customer_role = Role.find_by!(name: 'customer')

    UserTenantRole.find_or_create_by(user: user, tenant: tenant, role: customer_role) do |assignment|
      assignment.scope_type = :selected_courses
    end

    membership
  end
end