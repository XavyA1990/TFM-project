# frozen_string_literal: true

PASSWORD = "Password123!".freeze

ROLE_DEFINITIONS = {
  super_admin: "Full access across the platform",
  platform_admin: "Administrative access for a tenant",
  course_admin: "Course management access for a tenant",
  supervisor: "Supervision access for a tenant",
  customer: "Customer access for a tenant"
}.freeze

PERMISSION_DEFINITIONS = [
  {
    name: "read_tenant",
    action: "read",
    subject_class: "Tenant",
    description: "View tenant information"
  },
  {
    name: "update_tenant",
    action: "update",
    subject_class: "Tenant",
    description: "Update tenant information"
  },
  {
    name: "read_user",
    action: "read",
    subject_class: "User",
    description: "View users"
  },
  {
    name: "create_user",
    action: "create",
    subject_class: "User",
    description: "Create users"
  },
  {
    name: "update_user",
    action: "update",
    subject_class: "User",
    description: "Update users"
  },
  {
    name: "read_role",
    action: "read",
    subject_class: "Role",
    description: "View roles"
  },
  {
    name: "assign_role",
    action: "assign",
    subject_class: "Role",
    description: "Assign roles to users"
  },
  {
    name: "read_permission",
    action: "read",
    subject_class: "Permission",
    description: "View permissions"
  },
  {
    name: "manage_course",
    action: "manage",
    subject_class: "Course",
    description: "Create and manage courses"
  },
  {
    name: "read_course",
    action: "read",
    subject_class: "Course",
    description: "View courses"
  },
  {
    name: "read_report",
    action: "read",
    subject_class: "Report",
    description: "View reports"
  }
].freeze

ROLE_PERMISSION_MAP = {
  super_admin: [],
  platform_admin: %w[
    read_tenant update_tenant
    read_user create_user update_user
    read_role assign_role
    read_permission
    read_course read_report
  ],
  course_admin: %w[
    read_tenant
    read_user
    manage_course read_report
  ],
  supervisor: %w[
    read_tenant
    read_user
    read_course read_report
  ],
  customer: %w[
    read_tenant
    read_course
  ]
}.freeze

TENANT_DEFINITIONS = [
  { name: "Acme Learning", slug: "acme-learning" },
  { name: "Northwind Academy", slug: "northwind-academy" },
  { name: "Globex Institute", slug: "globex-institute" },
  { name: "Initech Campus", slug: "initech-campus" },
  { name: "Umbrella Training", slug: "umbrella-training" }
].freeze

def create_role!(name, description)
  role = Role.find_or_initialize_by(name: name.to_s)
  role.description = description
  role.save! if role.new_record? || role.changed?
  role
end

def create_permission!(name:, action:, subject_class:, description:)
  permission = Permission.find_or_initialize_by(name: name)
  permission.action = action
  permission.subject_class = subject_class
  permission.description = description
  permission.save! if permission.new_record? || permission.changed?
  permission
end

def create_user!(email:, username:, first_name:, last_name:, is_super_admin: false)
  user = User.find_or_initialize_by(email: email)
  user.username = username
  user.first_name = first_name
  user.last_name = last_name
  user.is_super_admin = is_super_admin
  user.password = PASSWORD if user.new_record?
  user.password_confirmation = PASSWORD if user.new_record?
  user.confirmed_at ||= Time.current
  user.save! if user.new_record? || user.changed?
  user
end

def assign_role!(user:, tenant:, role:, scope_type: :tenant)
  membership = UsersTenant.find_or_create_by!(user: user, tenant: tenant)
  assignment = UserTenantRole.find_or_initialize_by(users_tenant: membership, role: role)
  assignment.scope_type = scope_type
  assignment.save! if assignment.new_record? || assignment.changed?
end

def assign_permission!(role:, permission:)
  RolePermission.find_or_create_by!(role: role, permission: permission)
end

roles = ROLE_DEFINITIONS.to_h do |name, description|
  [name, create_role!(name, description)]
end

permissions = PERMISSION_DEFINITIONS.to_h do |permission_attrs|
  [
    permission_attrs[:name],
    create_permission!(**permission_attrs)
  ]
end

RolePermission.joins(:permission).where(permissions: { name: "manage_all" }).destroy_all
Permission.where(name: "manage_all").destroy_all

ROLE_PERMISSION_MAP.each do |role_name, permission_names|
  permission_names.each do |permission_name|
    assign_permission!(role: roles.fetch(role_name), permission: permissions.fetch(permission_name))
  end
end

tenants = TENANT_DEFINITIONS.map do |tenant_attrs|
  tenant = Tenant.find_or_initialize_by(slug: tenant_attrs[:slug])
  tenant.name = tenant_attrs[:name]
  tenant.save! if tenant.new_record? || tenant.changed?
  tenant
end

super_admin = create_user!(
  email: ENV["SUPER_ADMIN_EMAIL"] || "superadmin@example.com",
  username: "superadmin",
  first_name: "Super",
  last_name: "Admin",
  is_super_admin: true
)

tenants.each do |tenant|
  assign_role!(user: super_admin, tenant: tenant, role: roles[:super_admin], scope_type: :tenant)
end

tenants.each_with_index do |tenant, index|
  tenant_key = index + 1

  platform_admin = create_user!(
    email: "platform.admin#{tenant_key}@example.com",
    username: "platform_admin_#{tenant_key}",
    first_name: "Platform",
    last_name: "Admin#{tenant_key}"
  )
  assign_role!(user: platform_admin, tenant: tenant, role: roles[:platform_admin], scope_type: :tenant)

  course_admin = create_user!(
    email: "course.admin#{tenant_key}@example.com",
    username: "course_admin_#{tenant_key}",
    first_name: "Course",
    last_name: "Admin#{tenant_key}"
  )
  assign_role!(user: course_admin, tenant: tenant, role: roles[:course_admin], scope_type: :tenant)

  supervisor = create_user!(
    email: "supervisor#{tenant_key}@example.com",
    username: "supervisor_#{tenant_key}",
    first_name: "Supervisor",
    last_name: tenant_key.to_s
  )
  assign_role!(user: supervisor, tenant: tenant, role: roles[:supervisor], scope_type: :tenant)

  2.times do |customer_index|
    customer_number = customer_index + 1
    customer = create_user!(
      email: "customer#{tenant_key}_#{customer_number}@example.com",
      username: "customer_#{tenant_key}_#{customer_number}",
      first_name: "Customer",
      last_name: "#{tenant_key}_#{customer_number}"
    )
    assign_role!(user: customer, tenant: tenant, role: roles[:customer], scope_type: :selected_courses)
  end
end

puts "Seeded #{Role.count} roles"
puts "Seeded #{Permission.count} permissions"
puts "Seeded #{RolePermission.count} role permissions"
puts "Seeded #{Tenant.count} tenants"
puts "Seeded #{User.count} users"
puts "Default password for seeded users: #{PASSWORD}"
