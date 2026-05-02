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

TENANT_DEFINITIONS = [
  { name: "Acme Learning", slug: "acme-learning" },
  { name: "Northwind Academy", slug: "northwind-academy" },
  { name: "Globex Institute", slug: "globex-institute" },
  { name: "Initech Campus", slug: "initech-campus" },
  { name: "Umbrella Training", slug: "umbrella-training" }
].freeze

COURSE_DEFINITIONS = [
  {
    title: "Onboarding Fundamentals",
    slug: "onboarding-fundamentals",
    short_description: "Essential onboarding path for new participants.",
    description: "A practical introduction to the platform, the learning flow, and the expectations for the first training cycle.",
    status: "published",
    modules: [
      {
        title: "Getting Started",
        slug: "getting-started",
        description: "Core orientation materials for first-time learners.",
        position: 0,
        status: "published",
        lessons: [
          {
            title: "Welcome and Orientation",
            slug: "welcome-and-orientation",
            description: "Overview of the program and learning goals.",
            lesson_type: "text",
            status: "published",
            position: 0,
            body: "Welcome to the program. In this lesson we review the structure of the tenant portal, the expected progress, and the outcomes you should reach during the first week."
          },
          {
            title: "Platform Walkthrough",
            slug: "platform-walkthrough",
            description: "Guided tour of the learning platform.",
            lesson_type: "video",
            status: "published",
            position: 1,
            content_url: "https://example.com/videos/platform-walkthrough"
          },
          {
            title: "Quick Start Checklist",
            slug: "quick-start-checklist",
            description: "Reference checklist for the first login.",
            lesson_type: "pdf",
            status: "published",
            position: 2,
            content_url: "https://example.com/docs/quick-start-checklist.pdf"
          }
        ]
      },
      {
        title: "Learning Guidelines",
        slug: "learning-guidelines",
        description: "Standards and best practices for successful course completion.",
        position: 1,
        status: "published",
        lessons: [
          {
            title: "Participation Standards",
            slug: "participation-standards",
            description: "How learners are expected to engage with the course.",
            lesson_type: "text",
            status: "published",
            position: 0,
            body: "Complete every module in sequence, keep your profile up to date, and use the provided materials before asking for support."
          },
          {
            title: "Progress Tracking",
            slug: "progress-tracking",
            description: "How to monitor and report your progress.",
            lesson_type: "image",
            status: "published",
            position: 1,
            content_url: "https://example.com/images/progress-tracking-dashboard.png"
          }
        ]
      }
    ]
  },
  {
    title: "Team Communication Essentials",
    slug: "team-communication-essentials",
    short_description: "Build a consistent communication baseline across teams.",
    description: "This course covers communication norms, escalation paths, and collaboration patterns used across operational teams.",
    status: "published",
    modules: [
      {
        title: "Communication Foundations",
        slug: "communication-foundations",
        description: "Common language and expectations for internal communication.",
        position: 0,
        status: "published",
        lessons: [
          {
            title: "Choosing the Right Channel",
            slug: "choosing-the-right-channel",
            description: "When to use chat, email, or formal documentation.",
            lesson_type: "text",
            status: "published",
            position: 0,
            body: "Effective communication starts with choosing the correct channel. Use persistent documentation for decisions, chat for quick coordination, and email for formal follow-up."
          },
          {
            title: "Escalation Matrix",
            slug: "escalation-matrix",
            description: "Escalation path for incidents and blockers.",
            lesson_type: "pdf",
            status: "published",
            position: 1,
            content_url: "https://example.com/docs/escalation-matrix.pdf"
          }
        ]
      },
      {
        title: "Collaborative Execution",
        slug: "collaborative-execution",
        description: "Methods for coordination and handoff between teams.",
        position: 1,
        status: "draft",
        lessons: [
          {
            title: "Meeting Cadence",
            slug: "meeting-cadence",
            description: "Recommended cadence for operational syncs.",
            lesson_type: "text",
            status: "draft",
            position: 0,
            body: "Weekly planning, mid-week check-ins, and end-of-cycle retrospectives provide enough structure without creating unnecessary overhead."
          },
          {
            title: "Documentation Handoffs",
            slug: "documentation-handoffs",
            description: "How to leave clean handoffs for the next team.",
            lesson_type: "video",
            status: "draft",
            position: 1,
            content_url: "https://example.com/videos/documentation-handoffs"
          }
        ]
      }
    ]
  },
  {
    title: "Operational Excellence Basics",
    slug: "operational-excellence-basics",
    short_description: "Introduce core operational quality and reporting practices.",
    description: "A baseline course focused on repeatable execution, issue prevention, and continuous improvement habits.",
    status: "draft",
    modules: [
      {
        title: "Quality Routines",
        slug: "quality-routines",
        description: "Daily and weekly routines that improve operational quality.",
        position: 0,
        status: "draft",
        lessons: [
          {
            title: "Daily Review Workflow",
            slug: "daily-review-workflow",
            description: "Checklist for a standard daily review.",
            lesson_type: "text",
            status: "draft",
            position: 0,
            body: "Start by reviewing pending work, unresolved blockers, and key metrics. End the review by documenting risks and the next concrete action."
          },
          {
            title: "Issue Categorization",
            slug: "issue-categorization",
            description: "Classify issues by impact and urgency.",
            lesson_type: "image",
            status: "draft",
            position: 1,
            content_url: "https://example.com/images/issue-categorization-matrix.png"
          }
        ]
      },
      {
        title: "Reporting Basics",
        slug: "reporting-basics",
        description: "Fundamentals of concise and useful reporting.",
        position: 1,
        status: "draft",
        lessons: [
          {
            title: "Weekly Status Summary",
            slug: "weekly-status-summary",
            description: "Structure a weekly status report.",
            lesson_type: "text",
            status: "draft",
            position: 0,
            body: "A strong weekly update reports outcomes, current risks, next actions, and any decisions that need review."
          }
        ]
      }
    ]
  }
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

def create_course!(tenant:, attrs:)
  course = Course.find_or_initialize_by(tenant: tenant, slug: attrs[:slug])
  course.title = attrs[:title]
  course.short_description = attrs[:short_description]
  course.description = attrs[:description]
  course.status = attrs[:status]
  course.save! if course.new_record? || course.changed?
  course
end

def create_course_module!(course:, attrs:)
  course_module = CourseModule.find_or_initialize_by(course: course, slug: attrs[:slug])
  course_module.title = attrs[:title]
  course_module.description = attrs[:description]
  course_module.position = attrs[:position]
  course_module.status = attrs[:status]
  course_module.save! if course_module.new_record? || course_module.changed?
  course_module
end

def create_lesson!(course_module:, attrs:)
  lesson = Lesson.find_or_initialize_by(course_module: course_module, slug: attrs[:slug])
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

tenants.each do |tenant|
  COURSE_DEFINITIONS.each do |course_attrs|
    course = create_course!(tenant: tenant, attrs: course_attrs)

    course_attrs[:modules].each do |module_attrs|
      course_module = create_course_module!(course: course, attrs: module_attrs)

      module_attrs[:lessons].each do |lesson_attrs|
        create_lesson!(course_module: course_module, attrs: lesson_attrs)
      end
    end
  end
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
puts "Seeded #{Course.count} courses"
puts "Seeded #{CourseModule.count} course modules"
puts "Seeded #{Lesson.count} lessons"
