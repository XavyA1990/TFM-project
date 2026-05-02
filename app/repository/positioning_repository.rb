class PositioningRepository
  def self.maximum_position(record, siblings)
    siblings.count
  end

  def self.change_siblings_position(siblings, from_position, to_position, amount:, excluded_record: nil)
    min_position, max_position = [from_position, to_position].minmax

    scope = siblings.where(position: min_position..max_position)
    scope = scope.where.not(id: excluded_record.id) if excluded_record.present?
    operation = amount.positive? ? "+" : "-"

    scope.update_all(["position = position #{operation} ?", amount.abs])
  end

  def self.update_position(record, position)
    record.update(position: position)
    record
  end

  def self.assign_position(record, position)
    record.position = position
    record
  end
end
