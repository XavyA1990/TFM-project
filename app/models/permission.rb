class Permission < ApplicationRecord
  has_many :role_permissions
  has_many :roles, through: :role_permissions

  validates :name, presence: true
  validates :action, presence: true
  validates :subject_class, presence: true
end