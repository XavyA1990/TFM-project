require "rails_helper"

RSpec.describe UsersTenant, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:tenant) }
    it { is_expected.to have_many(:user_tenant_roles) }
    it { is_expected.to have_many(:roles).through(:user_tenant_roles) }
  end

  describe "#roles" do
    it "returns the roles associated with the membership" do
      membership = create(:users_tenant)
      role_a = create(:role)
      role_b = create(:role)

      create(:user_tenant_role, users_tenant: membership, role: role_a)
      create(:user_tenant_role, users_tenant: membership, role: role_b)

      expect(membership.roles).to contain_exactly(role_a, role_b)
    end
  end

  describe "#permissions" do
    it "returns distinct permissions across membership roles" do
      membership = create(:users_tenant)
      role_a = create(:role)
      role_b = create(:role)
      shared_permission = create(:permission)
      unique_permission = create(:permission)

      create(:user_tenant_role, users_tenant: membership, role: role_a)
      create(:user_tenant_role, users_tenant: membership, role: role_b)
      create(:role_permission, role: role_a, permission: shared_permission)
      create(:role_permission, role: role_b, permission: shared_permission)
      create(:role_permission, role: role_b, permission: unique_permission)

      expect(membership.permissions).to contain_exactly(shared_permission, unique_permission)
    end

    it "returns an empty relation when the membership has no roles" do
      membership = create(:users_tenant)

      expect(membership.permissions).to be_empty
    end
  end
end
