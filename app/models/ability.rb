# frozen_string_literal: true

class Ability
  include CanCan::Ability
  DASHBOARD_ACTION = :access_dashboard

  def initialize(user, tenant = nil)
    user ||= User.new

    if user.is_super_admin?
      can :manage, :all
      can :access, :super_admin_panel
      can DASHBOARD_ACTION, Tenant
      return
    end

    return unless user.persisted?
    return unless tenant.present?
    return unless user.membership_for(tenant)

    can DASHBOARD_ACTION, tenant if user.can_access_dashboard_for?(tenant)

    user.permissions_for(tenant).each do |permission|
      subject = safe_constantize(permission.subject_class)

      next unless subject

      can permission.action.to_sym, subject
    end
  end

  private

  def safe_constantize(class_name)
    class_name.safe_constantize
  end
end
