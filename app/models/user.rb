class User < ApplicationRecord
  extend FriendlyId
  friendly_id :username, use: :slugged
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable
         
  has_many :users_tenants
  has_many :tenants, through: :users_tenants
  
  validates :username, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :slug, uniqueness: true

  def should_generate_new_friendly_id?
    will_save_change_to_username? || super
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

  def has_permission_in_tenant?(action, subject_class, tenant)
    permissions_for(tenant).any? do |permission|
      permission.action == action && permission.subject_class == subject_class
    end
  end
end
