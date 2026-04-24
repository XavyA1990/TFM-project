class TenantsRepository
  def self.all
    Tenant.all
  end

  def self.all_ordered
    Tenant.order(created_at: :desc)
  end

  def self.all_ordered_by_name
    Tenant.order(:name)
  end

  def self.find(id)
    Tenant.find(id)
  end

  def self.find_by_slug(slug)
    Tenant.friendly.find(slug)
  end

  def self.create(params)
    Tenant.create(params)
  end

  def self.update(id, params)
    tenant = Tenant.find(id)
    tenant.update(params)
    tenant
  end

  def self.destroy(id)
    tenant = Tenant.find(id)
    tenant.destroy
  end
end
