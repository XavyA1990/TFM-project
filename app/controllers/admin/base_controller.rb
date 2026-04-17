class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_super_admin_status

  private

  def validate_super_admin_status
    redirect_to root_path, alert: t("authorization.denied") unless current_user.is_super_admin?
  end
end
