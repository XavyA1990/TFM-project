class Users::RegistrationsController < Devise::RegistrationsController
  after_action :ensure_customer_membership, only: [:create], if: :resource_persisted?

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?

    prepared_avatar = prepare_avatar_asset(resource)

    if resource.errors.any?
      clean_up_passwords(resource)
      set_minimum_password_length
      render :edit, status: :unprocessable_entity
      return
    end

    resource_updated = false

    User.transaction do
      resource_updated = Users::ProfileServices.new(
        :update,
        { user: resource, attributes: account_update_params.except(:avatar_asset) }
      ).call

      raise ActiveRecord::Rollback unless resource_updated

      attach_avatar_asset(resource, prepared_avatar)

      if resource.errors.any?
        resource_updated = false
        raise ActiveRecord::Rollback
      end
    end

    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
      respond_with resource, location: after_update_path_for(resource)
      return
    end

    clean_up_passwords(resource)
    set_minimum_password_length
    respond_with resource, status: :unprocessable_entity
  end

  private

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  def ensure_customer_membership
    return unless current_tenant.present?
    
    Users::EnsureCustomerMembership.call(user: resource, tenant: current_tenant)
  end

  def prepare_avatar_asset(user)
    avatar_blob_id = params.dig(resource_name, :avatar_asset)
    return nil if avatar_blob_id.blank?

    Users::ProfileAssetsServices.new(
      :prepare_avatar,
      { user: user, signed_blob_id: avatar_blob_id }
    ).call
  end

  def attach_avatar_asset(user, prepared_avatar)
    return if prepared_avatar.blank?

    Users::ProfileAssetsServices.new(
      :attach_avatar,
      { user: user, prepared_asset: prepared_avatar }
    ).call
  end

  def after_sign_up_path_for(resource)
    tenant = origin_tenant
    
    return root_path unless tenant.present?

    tenant_root_path(tenant_slug: tenant.slug)
  end

  def origin_tenant
    slug = cookies.signed[:origin_tenant_slug]
    return nil unless slug.present?

    Tenant.friendly.find(slug)
  end
end
