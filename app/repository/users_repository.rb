class UsersRepository
  def self.all
    User.all
  end

  def self.all_with_tenants_and_roles
    User.includes(users_tenants: [:tenant, :roles]).order(created_at: :desc)
  end

  def self.find(id)
    User.find(id)
  end

  def self.find_by_slug(slug)
    User.friendly.find(slug)
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
