module Tenants
  class AssetsServices
    def initialize(action, params, ingestion_service: Assets::IngestionServices, repository: AssetsRepository)
      @action = action
      @params = params
      @ingestion_service = ingestion_service
      @repository = repository
      @tenant = params[:tenant]
    end

    def call
      return prepare_logo if @action == :prepare_logo
      return attach_logo if @action == :attach_logo

      raise ArgumentError, I18n.t("services.errors.invalid_action")
    end

    private

    def prepare_logo
      @ingestion_service.new(
        :prepare,
        {
          record: @tenant,
          signed_blob_id: @params[:signed_blob_id],
          profile: :tenant_logo
        }
      ).call
    rescue ArgumentError => error
      @tenant.errors.add(:logo_asset, error.message)
      nil
    end

    def attach_logo
      prepared_asset = @params[:prepared_asset]
      return @tenant if prepared_asset.blank?

      @repository.attach_asset(**prepared_asset)
    rescue StandardError => error
      @tenant.errors.add(:logo_asset, error.message)
      @tenant
    end
  end
end
