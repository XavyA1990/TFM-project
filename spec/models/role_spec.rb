require "rails_helper"

RSpec.describe Role, type: :model do
  subject(:role) { create(:role) }

  describe "validations" do
    it "builds a valid role from the factory" do
      expect(build(:role)).to be_valid
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_length_of(:description).is_at_most(255) }
  end

  describe "associations" do
    it { is_expected.to have_many(:user_tenant_roles) }
    it { is_expected.to have_many(:users_tenants).through(:user_tenant_roles) }
    it { is_expected.to have_many(:role_permissions) }
    it { is_expected.to have_many(:permissions).through(:role_permissions) }
  end
end
