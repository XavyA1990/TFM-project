module Users
  class ProfileAssetsServices
    def initialize(action, params, ingestion_service: Assets::IngestionServices, repository: AssetsRepository)
      @action = action
      @params = params
      @ingestion_service = ingestion_service
      @repository = repository
      @user = params[:user]
    end

    def call
      return prepare_avatar if @action == :prepare_avatar
      return attach_avatar if @action == :attach_avatar

      raise ArgumentError, I18n.t("services.errors.invalid_action")
    end

    private

    def prepare_avatar
      @ingestion_service.new(
        :prepare,
        {
          record: @user,
          signed_blob_id: @params[:signed_blob_id],
          profile: :avatar_image
        }
      ).call
    rescue ArgumentError => error
      @user.errors.add(:avatar_asset, error.message)
      nil
    end

    def attach_avatar
      prepared_asset = @params[:prepared_asset]
      return @user if prepared_asset.blank?

      @repository.attach_asset(**prepared_asset)
    rescue StandardError => error
      @user.errors.add(:avatar_asset, error.message)
      @user
    end
  end
end
