class RolesRepository
  def self.find(id)
    Role.find(id)
  end

  def self.find_signed(signed_id, purpose:)
    Role.find_signed!(signed_id, purpose: purpose)
  end

  def self.find_by_name(name)
    Role.find_by!(name: name)
  end

  def self.all_ordered
    Role.order(:name)
  end

  def self.all_ordered_except(name)
    Role.where.not(name: name).order(:name)
  end
end
