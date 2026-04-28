class User < ApplicationRecord
  CUSTOMER_ROLE_NAME = "customer".freeze

  extend FriendlyId
  friendly_id :username, use: :slugged
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable
         
  has_many :users_tenants, dependent: :destroy
  has_many :tenants, through: :users_tenants

  has_one_attached :avatar_asset
  
  validates :username, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :slug, uniqueness: true

  def should_generate_new_friendly_id?
    will_save_change_to_username? || super
  end

  def avatar_source
    return avatar_asset if avatar_asset.attached?
    return avatar_url if avatar_url.present?

    "default_avatar.svg"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def membership_for(tenant)
    users_tenants.find_by(tenant: tenant)
  end

  def roles_for(tenant)
    membership = membership_for(tenant)
    membership ? membership.roles : []
  end

  def permissions_for(tenant)
    roles = roles_for(tenant)
    permissions = roles.flat_map(&:permissions).uniq
    permissions
  end

  def has_role_in_tenant?(role_name, tenant)
    roles_for(tenant).any? { |role| role.name == role_name }
  end

  def has_access_to_dashboard?
    dashboard_accessible_tenants.exists?
  end

  def can_access_dashboard_for?(tenant)
    membership = membership_for(tenant)
    return false unless membership.present?

    membership.roles.any? { |role| role.name != CUSTOMER_ROLE_NAME }
  end

  def dashboard_accessible_tenants
    return Tenant.none unless persisted?

    tenants.joins(users_tenants: :roles)
      .where(users_tenants: { user_id: id })
      .where.not(roles: { name: CUSTOMER_ROLE_NAME })
      .distinct
      .order(:name)
  end

  def get_tenants_dashboard_access_paths
    dashboard_accessible_tenants.map do |tenant|
      {
        name: tenant.name,
        path: Rails.application.routes.url_helpers.admin_tenants_tenant_path({ tenant_slug: tenant.slug })
      }
    end
  end

  def self.table_columns
    %i[full_name email tenant_role created_at updated_at]
  end

  def has_permission_in_tenant?(action, subject_class, tenant)
    permissions_for(tenant).any? do |permission|
      permission.action == action && permission.subject_class == subject_class
    end
  end
end
