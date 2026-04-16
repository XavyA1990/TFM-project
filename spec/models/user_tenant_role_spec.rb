require "rails_helper"

RSpec.describe UserTenantRole, type: :model do
  subject(:user_tenant_role) { build(:user_tenant_role) }

  describe "validations" do
    it "builds a valid record from the factory" do
      expect(build(:user_tenant_role)).to be_valid
    end

    it { is_expected.to validate_presence_of(:scope_type) }
    it do
      is_expected.to validate_uniqueness_of(:users_tenant_id)
        .scoped_to(:role_id)
        .ignoring_case_sensitivity
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:users_tenant) }
    it { is_expected.to belong_to(:role) }
  end

  describe "enums" do
    it "defines the expected scope types" do
      expect(described_class.scope_types).to eq(
        "selected_courses" => "selected_courses",
        "tenant" => "tenant"
      )
    end
  end
end
