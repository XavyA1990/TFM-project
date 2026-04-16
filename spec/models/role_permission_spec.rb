require "rails_helper"

RSpec.describe RolePermission, type: :model do
  subject(:role_permission) { build(:role_permission) }

  describe "validations" do
    it "builds a valid role permission from the factory" do
      expect(build(:role_permission)).to be_valid
    end

    it do
      is_expected.to validate_uniqueness_of(:role_id)
        .scoped_to(:permission_id)
        .ignoring_case_sensitivity
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:role) }
    it { is_expected.to belong_to(:permission) }
  end
end
