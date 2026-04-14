class Tenant < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :users_tenants
  has_many :users, through: :users_tenants

  def should_generate_new_friendly_id?
    will_save_change_to_name? || super
  end
end