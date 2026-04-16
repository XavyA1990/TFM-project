require "rails_helper"

RSpec.describe Permission, type: :model do
  subject(:permission) { create(:permission) }

  describe "validations" do
    it "builds a valid permission from the factory" do
      expect(build(:permission)).to be_valid
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_presence_of(:subject_class) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_length_of(:description).is_at_most(255) }
  end

  describe "associations" do
    it { is_expected.to have_many(:role_permissions) }
    it { is_expected.to have_many(:roles).through(:role_permissions) }
  end
end
