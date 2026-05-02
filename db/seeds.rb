# frozen_string_literal: true

require "faker"

PASSWORD = "Password123!".freeze
SEED_VALUE = ENV["SEED_VALUE"] ? ENV["SEED_VALUE"].to_i : 12345
TENANT_COUNT = 5
COURSE_COUNT = 6
MODULES_PER_COURSE = 2
LESSONS_PER_MODULE = 3
PUBLISHED_COURSE_COUNT = 5
LESSON_TYPES = %w[text video pdf image].freeze

Faker::Config.random = Random.new(SEED_VALUE)
Faker::UniqueGenerator.clear
srand(SEED_VALUE)

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
    read_permission manage_course
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

def tenant_definitions
  @tenant_definitions ||= Array.new(TENANT_COUNT) do
    { name: Faker::Company.unique.name }
  end
end

def course_definitions
  @course_definitions ||= Array.new(COURSE_COUNT) do |course_index|
    course_status = course_index < PUBLISHED_COURSE_COUNT ? "published" : "draft"

    {
      title: faker_title(word_count: 3),
      short_description: Faker::Lorem.sentence(word_count: 8),
      description: Faker::Lorem.paragraph(sentence_count: 3),
      status: course_status,
      modules: module_definitions(course_status: course_status)
    }
  end
end

def module_definitions(course_status:)
  Array.new(MODULES_PER_COURSE) do |module_index|
    {
      title: faker_title(word_count: 2),
      description: Faker::Lorem.paragraph(sentence_count: 2),
      position: module_index + 1,
      status: course_status,
      lessons: lesson_definitions(course_status: course_status)
    }
  end
end

def lesson_definitions(course_status:)
  Array.new(LESSONS_PER_MODULE) do |lesson_index|
    lesson_type = LESSON_TYPES[lesson_index % LESSON_TYPES.length]
    title = faker_title(word_count: 3)
    text_body = Faker::Lorem.paragraphs(number: 2).join("\n\n")

    {
      title: title,
      description: Faker::Lorem.sentence(word_count: 10),
      lesson_type: lesson_type,
      status: course_status,
      position: lesson_index + 1,
      body: text_body,
      content_url: nil
    }
  end
end

def faker_title(word_count:)
  Faker::Lorem.unique.sentence(word_count: word_count).delete(".")
end

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

def create_tenant!(attrs:)
  tenant = Tenant.find_by(name: attrs[:name]) || Tenant.new
  tenant.name = attrs[:name]
  tenant.save! if tenant.new_record? || tenant.changed?
  tenant
end

def create_course!(tenant:, attrs:)
  course = Course.find_or_initialize_by(tenant: tenant, title: attrs[:title])
  course.title = attrs[:title]
  course.short_description = attrs[:short_description]
  course.description = attrs[:description]
  course.status = attrs[:status]
  course.save! if course.new_record? || course.changed?
  course
end

def create_course_module!(course:, attrs:)
  course_module = CourseModule.find_or_initialize_by(course: course, title: attrs[:title])
  course_module.title = attrs[:title]
  course_module.description = attrs[:description]
  course_module.position = attrs[:position]
  course_module.status = attrs[:status]
  course_module.save! if course_module.new_record? || course_module.changed?
  course_module
end

def create_lesson!(course_module:, attrs:)
  lesson = Lesson.find_or_initialize_by(course_module: course_module, title: attrs[:title])
  lesson.title = attrs[:title]
  lesson.description = attrs[:description]
  lesson.body = attrs[:body]
  lesson.content_url = attrs[:content_url]
  lesson.lesson_type = attrs[:lesson_type]
  lesson.position = attrs[:position]
  lesson.status = attrs[:status]
  lesson.save! if lesson.new_record? || lesson.changed?
  lesson
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

tenants = tenant_definitions.each_with_index.map do |tenant_attrs, index|
  create_tenant!(attrs: tenant_attrs)
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

tenants.each do |tenant|

  course_definitions.each do |course_attrs|
    course = create_course!(tenant: tenant, attrs: course_attrs)

    course_attrs[:modules].each do |module_attrs|
      course_module = create_course_module!(course: course, attrs: module_attrs)

      module_attrs[:lessons].each do |lesson_attrs|
        create_lesson!(course_module: course_module, attrs: lesson_attrs)
      end
    end
  end
end

tenants.each do |tenant|
  tenant_key = tenant.slug
  tenant_key_username = tenant.slug.tr("-", "_")

  platform_admin = create_user!(
    email: "platform.admin.#{tenant_key}@example.com",
    username: "platform_admin_#{tenant_key_username}",
    first_name: "Platform",
    last_name: "Admin #{tenant_key}"
  )
  assign_role!(user: platform_admin, tenant: tenant, role: roles[:platform_admin], scope_type: :tenant)

  course_admin = create_user!(
    email: "course.admin.#{tenant_key}@example.com",
    username: "course_admin_#{tenant_key_username}",
    first_name: "Course",
    last_name: "Admin #{tenant_key}"
  )
  assign_role!(user: course_admin, tenant: tenant, role: roles[:course_admin], scope_type: :tenant)

  supervisor = create_user!(
    email: "supervisor.#{tenant_key}@example.com",
    username: "supervisor_#{tenant_key_username}",
    first_name: "Supervisor",
    last_name: tenant_key
  )
  assign_role!(user: supervisor, tenant: tenant, role: roles[:supervisor], scope_type: :tenant)

  2.times do |customer_index|
    customer_number = customer_index + 1
    customer = create_user!(
      email: "customer.#{tenant_key}.#{customer_number}@example.com",
      username: "customer_#{tenant_key_username}_#{customer_number}",
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
puts "Seeded #{Course.count} courses"
puts "Seeded #{CourseModule.count} course modules"
puts "Seeded #{Lesson.count} lessons"
