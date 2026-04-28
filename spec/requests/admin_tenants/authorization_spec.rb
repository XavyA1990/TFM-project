require "rails_helper"

RSpec.describe "Admin tenants authorization", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:locale) { I18n.default_locale }
  let!(:customer_role) { create(:role, name: "customer") }
  let!(:platform_admin_role) { create(:role, name: "platform_admin") }
  let!(:supervisor_role) { create(:role, name: "supervisor") }
  let!(:read_tenant_permission) { create(:permission, name: "read_tenant", action: "read", subject_class: "Tenant") }
  let!(:update_tenant_permission) { create(:permission, name: "update_tenant", action: "update", subject_class: "Tenant") }
  let!(:read_user_permission) { create(:permission, name: "read_user", action: "read", subject_class: "User") }
  let!(:assign_role_permission) { create(:permission, name: "assign_role", action: "assign", subject_class: "Role") }

  before do
    create(:role_permission, role: customer_role, permission: read_tenant_permission)

    create(:role_permission, role: supervisor_role, permission: read_tenant_permission)
    create(:role_permission, role: supervisor_role, permission: read_user_permission)

    create(:role_permission, role: platform_admin_role, permission: read_tenant_permission)
    create(:role_permission, role: platform_admin_role, permission: update_tenant_permission)
    create(:role_permission, role: platform_admin_role, permission: read_user_permission)
    create(:role_permission, role: platform_admin_role, permission: assign_role_permission)
  end

  def assign_role_to_tenant(user:, tenant:, role:, scope_type:)
    membership = UsersTenant.find_or_create_by!(user: user, tenant: tenant)
    UserTenantRole.create!(users_tenant: membership, role: role, scope_type: scope_type)
  end

  describe "navbar dashboard links" do
    it "shows only tenants where the user has a non-customer role" do
      customer_tenant = create(:tenant, name: "Customer Tenant")
      admin_tenant = create(:tenant, name: "Admin Tenant")
      user = create(:user)

      assign_role_to_tenant(user: user, tenant: customer_tenant, role: customer_role, scope_type: :selected_courses)
      assign_role_to_tenant(user: user, tenant: admin_tenant, role: supervisor_role, scope_type: :tenant)

      sign_in user

      get root_path(locale: locale)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(admin_tenants_tenant_path(locale: locale, tenant_slug: admin_tenant.slug))
      expect(response.body).not_to include(admin_tenants_tenant_path(locale: locale, tenant_slug: customer_tenant.slug))
    end
  end

  describe "customer-only access" do
    it "redirects a customer away from the tenant dashboard" do
      tenant = create(:tenant)
      user = create(:user)
      assign_role_to_tenant(user: user, tenant: tenant, role: customer_role, scope_type: :selected_courses)

      sign_in user

      get admin_tenants_tenant_path(locale: locale, tenant_slug: tenant.slug)

      expect(response).to redirect_to(root_path(locale: locale))
    end
  end

  describe "supervisor access" do
    it "allows read-only dashboard access and hides restricted controls" do
      tenant = create(:tenant)
      supervisor = create(:user)
      managed_user = create(:user)

      assign_role_to_tenant(user: supervisor, tenant: tenant, role: supervisor_role, scope_type: :tenant)
      assign_role_to_tenant(user: managed_user, tenant: tenant, role: customer_role, scope_type: :selected_courses)

      sign_in supervisor

      get admin_tenants_tenant_path(locale: locale, tenant_slug: tenant.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(admin_tenants_users_path(locale: locale, tenant_slug: tenant.slug))
      expect(response.body).not_to include(edit_admin_tenants_tenant_path(locale: locale, tenant_slug: tenant.slug))

      get admin_tenants_user_path(locale: locale, tenant_slug: tenant.slug, id: managed_user.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(
        admin_tenants_user_role_assignments_path(locale: locale, tenant_slug: tenant.slug, user_id: managed_user.slug)
      )

      get edit_admin_tenants_tenant_path(locale: locale, tenant_slug: tenant.slug)

      expect(response).to redirect_to(root_path(locale: locale))

      post admin_tenants_user_role_assignments_path(locale: locale, tenant_slug: tenant.slug, user_id: managed_user.slug),
        params: { role_token: platform_admin_role.signed_id(purpose: :role_assignment) }

      expect(response).to redirect_to(root_path(locale: locale))
    end
  end

  describe "platform admin access" do
    it "shows management controls and allows role assignment" do
      tenant = create(:tenant)
      platform_admin = create(:user)
      managed_user = create(:user)

      assign_role_to_tenant(user: platform_admin, tenant: tenant, role: platform_admin_role, scope_type: :tenant)
      assign_role_to_tenant(user: managed_user, tenant: tenant, role: customer_role, scope_type: :selected_courses)

      sign_in platform_admin

      get admin_tenants_tenant_path(locale: locale, tenant_slug: tenant.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(edit_admin_tenants_tenant_path(locale: locale, tenant_slug: tenant.slug))

      get admin_tenants_user_path(locale: locale, tenant_slug: tenant.slug, id: managed_user.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(
        admin_tenants_user_role_assignments_path(locale: locale, tenant_slug: tenant.slug, user_id: managed_user.slug)
      )

      post admin_tenants_user_role_assignments_path(locale: locale, tenant_slug: tenant.slug, user_id: managed_user.slug),
        params: { role_token: supervisor_role.signed_id(purpose: :role_assignment) }

      expect(response).to redirect_to(
        admin_tenants_user_path(locale: locale, tenant_slug: tenant.slug, id: managed_user.slug)
      )
      expect(managed_user.has_role_in_tenant?("supervisor", tenant)).to be(true)
    end
  end
end
