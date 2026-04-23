class Tenant < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :users_tenants, dependent: :destroy
  has_many :users, through: :users_tenants

  validates :name, presence: true
  validates :slug, uniqueness: true

  def should_generate_new_friendly_id?
    will_save_change_to_name? || super
  end
  
  def self.table_columns
    %w[name slug created_at updated_at]
  end
end