class AssetsRepository
  def self.attach_asset(record:, attachment_name:, blob:)
    record.public_send(attachment_name).attach(blob)

    record
  end

  def self.purge_asset(record:, attachment_name:)
    record.public_send(attachment_name).purge if record.public_send(attachment_name).attached?
  end

  def self.purge_blob(blob:)
    blob.purge
  end
end
