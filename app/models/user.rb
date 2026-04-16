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


end
