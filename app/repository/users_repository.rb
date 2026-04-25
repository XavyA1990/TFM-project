class UsersRepository
  def self.all
    User.all
  end

  def self.all_with_tenants_and_roles
    User.includes(users_tenants: [:tenant, :roles]).order(created_at: :desc)
  end

  def self.all_for_tenant_with_tenants_and_roles(tenant)
    User.joins(:users_tenants)
        .where(users_tenants: { tenant_id: tenant.id })
        .includes(users_tenants: [:tenant, :roles])
        .distinct
        .order(created_at: :desc)
  end

  def self.find(id)
    User.find(id)
  end

  def self.find_by_slug(slug)
    User.friendly.find(slug)
  end

  def self.find_by_slug_in_tenant(slug, tenant)
    User.joins(:users_tenants)
        .where(users_tenants: { tenant_id: tenant.id })
        .distinct
        .friendly
        .find(slug)
  end

  def self.create(params)
    User.create(params)
  end

  def self.update(user, params)
    user.update(params)
  end

  def self.destroy(user)
    user.destroy
  end
end
