# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user, tenant = nil)
    user ||= User.new

    if user.is_super_admin?
      can :manage, :all
      return
    end

    return unless user.persisted? 
    return unless tenant.present?
    return unless user.membership_for(tenant)

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
