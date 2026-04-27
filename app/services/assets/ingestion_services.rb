module Assets
  class IngestionServices
    def initialize(action, params, repository: AssetsRepository)
      @action = action
      @params = params
      @repository = repository
    end

    def call
      return prepare_asset if @action == :prepare
      return attach_asset if @action == :attach

      raise ArgumentError, "Unknown action: #{@action}"
    end

    private

    def prepare_asset
      record = @params[:record]
      signed_blob_id = @params[:signed_blob_id]
      raise ArgumentError, "Missing file" if signed_blob_id.blank?

      blob = nil
      blob = ActiveStorage::Blob.find_signed!(signed_blob_id)
      profile = UploadProfiles.fetch(@params[:profile])

      validate_blob!(blob, profile)

      {
        record: record,
        attachment_name: profile[:attachment_name],
        blob: blob,
      }
    rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
      raise ArgumentError, "Invalid file upload."
    rescue ArgumentError => error
      purge_blob_if_present(blob)
      raise error
    rescue StandardError
      purge_blob_if_present(blob)
      raise
    end

    def validate_blob!(blob, profile)
      raise ArgumentError, "Missing file" if blob.blank?
      raise ArgumentError, "File size exceeds the maximum allowed." if blob.byte_size > profile[:max_size]
      raise ArgumentError, "Invalid file type." unless profile[:allowed_types].include?(blob.content_type)
    end

    def purge_blob_if_present(blob)
      return if blob.blank?

      @repository.purge_blob(blob: blob)
    end

    def attach_asset
      prepared_asset = @params[:prepared_asset] || prepare_asset

      @repository.attach_asset(**prepared_asset)
    end
  end
end
