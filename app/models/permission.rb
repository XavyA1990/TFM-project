class Permission < ApplicationRecord
  has_many :role_permissions
  has_many :roles, through: :role_permissions

  validates :name, presence: true, uniqueness: true
  validates :action, presence: true
  validates :subject_class, presence: true
  validates :description, length: { maximum: 255 }, allow_blank: true
end