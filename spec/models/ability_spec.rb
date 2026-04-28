require "rails_helper"

RSpec.describe Ability, type: :model do
  subject(:ability) { described_class.new(user, tenant) }

  let(:tenant) { create(:tenant) }

  def assign_role_to_tenant(user:, tenant:, role:, scope_type:)
    membership = UsersTenant.find_or_create_by!(user: user, tenant: tenant)
    UserTenantRole.create!(users_tenant: membership, role: role, scope_type: scope_type)
  end

  def attach_permission(role:, name:, action:, subject_class:)
    permission = create(
      :permission,
      name: name,
      action: action,
      subject_class: subject_class
    )
    create(:role_permission, role: role, permission: permission)
  end

  context "when the user is a super admin" do
    let(:user) { create(:user, is_super_admin: true) }

    it "allows full access" do
      expect(ability.can?(:manage, Tenant)).to be(true)
      expect(ability.can?(:access, :super_admin_panel)).to be(true)
      expect(ability.can?(:access_dashboard, tenant)).to be(true)
    end
  end

  context "when the user is a platform admin in the tenant" do
    let(:user) { create(:user) }
    let(:role) { create(:role, name: "platform_admin") }

    before do
      attach_permission(role: role, name: "read_tenant", action: "read", subject_class: "Tenant")
      attach_permission(role: role, name: "update_tenant", action: "update", subject_class: "Tenant")
      attach_permission(role: role, name: "read_user", action: "read", subject_class: "User")
      attach_permission(role: role, name: "assign_role", action: "assign", subject_class: "Role")
      assign_role_to_tenant(user: user, tenant: tenant, role: role, scope_type: :tenant)
    end

    it "allows dashboard access and tenant administration actions" do
      expect(ability.can?(:access_dashboard, tenant)).to be(true)
      expect(ability.can?(:read, User)).to be(true)
      expect(ability.can?(:update, tenant)).to be(true)
      expect(ability.can?(:assign, Role)).to be(true)
    end
  end

  context "when the user is a supervisor in the tenant" do
    let(:user) { create(:user) }
    let(:role) { create(:role, name: "supervisor") }

    before do
      attach_permission(role: role, name: "read_tenant", action: "read", subject_class: "Tenant")
      attach_permission(role: role, name: "read_user", action: "read", subject_class: "User")
      assign_role_to_tenant(user: user, tenant: tenant, role: role, scope_type: :tenant)
    end

    it "allows dashboard access but not edit or role assignment actions" do
      expect(ability.can?(:access_dashboard, tenant)).to be(true)
      expect(ability.can?(:read, User)).to be(true)
      expect(ability.can?(:update, tenant)).to be(false)
      expect(ability.can?(:assign, Role)).to be(false)
    end
  end

  context "when the user is only a customer in the tenant" do
    let(:user) { create(:user) }
    let(:role) { create(:role, name: "customer") }

    before do
      attach_permission(role: role, name: "read_tenant", action: "read", subject_class: "Tenant")
      assign_role_to_tenant(user: user, tenant: tenant, role: role, scope_type: :selected_courses)
    end

    it "denies dashboard access" do
      expect(ability.can?(:read, tenant)).to be(true)
      expect(ability.can?(:access_dashboard, tenant)).to be(false)
    end
  end
end
