require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "validations" do
    it "builds a valid user from the factory" do
      expect(build(:user)).to be_valid
    end

    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:username) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "associations" do
    it { is_expected.to have_many(:users_tenants) }
    it { is_expected.to have_many(:tenants).through(:users_tenants) }
  end

  describe "friendly_id" do
    it "generates a slug from the username" do
      user = create(:user, username: "John Example")

      expect(user.slug).to eq("john-example")
    end

    it "regenerates the slug when the username changes" do
      user = create(:user, username: "original-user")

      user.update!(username: "updated-user")

      expect(user.slug).to eq("updated-user")
    end
  end

  describe "#full_name" do
    it "returns the first and last name combined" do
      user = build(:user, first_name: "Ada", last_name: "Lovelace")

      expect(user.full_name).to eq("Ada Lovelace")
    end
  end

  describe "#membership_for" do
    it "returns the membership for the provided tenant" do
      persisted_user = create(:user)
      tenant = create(:tenant)
      membership = create(:users_tenant, user: persisted_user, tenant: tenant)

      expect(persisted_user.membership_for(tenant)).to eq(membership)
    end

    it "returns nil when the user is not a member of the tenant" do
      persisted_user = create(:user)

      expect(persisted_user.membership_for(create(:tenant))).to be_nil
    end
  end

  describe "#roles_for" do
    it "returns the roles attached to the tenant membership" do
      persisted_user = create(:user)
      tenant = create(:tenant)
      membership = create(:users_tenant, user: persisted_user, tenant: tenant)
      role = create(:role)
      create(:user_tenant_role, users_tenant: membership, role: role)

      expect(persisted_user.roles_for(tenant)).to contain_exactly(role)
    end

    it "returns an empty array when no membership exists" do
      persisted_user = create(:user)

      expect(persisted_user.roles_for(create(:tenant))).to eq([])
    end
  end

  describe "#permissions_for" do
    it "returns unique permissions across all tenant roles" do
      persisted_user = create(:user)
      tenant = create(:tenant)
      membership = create(:users_tenant, user: persisted_user, tenant: tenant)
      role_a = create(:role)
      role_b = create(:role)
      shared_permission = create(:permission)
      extra_permission = create(:permission)

      create(:user_tenant_role, users_tenant: membership, role: role_a)
      create(:user_tenant_role, users_tenant: membership, role: role_b)
      create(:role_permission, role: role_a, permission: shared_permission)
      create(:role_permission, role: role_b, permission: shared_permission)
      create(:role_permission, role: role_b, permission: extra_permission)

      expect(persisted_user.permissions_for(tenant)).to contain_exactly(shared_permission, extra_permission)
    end

    it "returns an empty array when the user has no roles for the tenant" do
      persisted_user = create(:user)
      tenant = create(:tenant)
      create(:users_tenant, user: persisted_user, tenant: tenant)

      expect(persisted_user.permissions_for(tenant)).to eq([])
    end
  end
end
