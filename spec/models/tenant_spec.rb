require "rails_helper"

RSpec.describe Tenant, type: :model do
  subject(:tenant) { build(:tenant) }

  describe "validations" do
    it "builds a valid tenant from the factory" do
      expect(build(:tenant)).to be_valid
    end

    it { is_expected.to validate_presence_of(:name) }
    it "generates a unique slug when another tenant has the same name" do
      existing_tenant = create(:tenant, name: "Acme Campus")
      duplicate_tenant = create(:tenant, name: existing_tenant.name)

      expect(duplicate_tenant).to be_valid
      expect(duplicate_tenant.slug).not_to eq(existing_tenant.slug)
      expect(duplicate_tenant.slug).to match(/\Aacme-campus-[0-9a-f\-]{36}\z/)
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:users_tenants) }
    it { is_expected.to have_many(:users).through(:users_tenants) }
  end

  describe "friendly_id" do
    it "generates a slug from the name" do
      tenant = create(:tenant, name: "Acme Campus")

      expect(tenant.slug).to eq("acme-campus")
    end

    it "regenerates the slug when the name changes" do
      tenant = create(:tenant, name: "Campus One")

      tenant.update!(name: "Campus Two")

      expect(tenant.slug).to eq("campus-two")
    end
  end
end
