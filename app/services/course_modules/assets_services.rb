module CourseModules
  class AssetsServices
    def initialize(action, params, ingestion_service: Assets::IngestionServices, repository: AssetsRepository)
      @action = action
      @params = params
      @ingestion_service = ingestion_service
      @repository = repository
      @course_module = params[:course_module]
    end

    def call
      return prepare_cover_image if @action == :prepare_cover_image
      return attach_cover_image if @action == :attach_cover_image

      raise ArgumentError, "Invalid action"
    end

    private

    def prepare_cover_image
      @ingestion_service.new(
        :prepare,
        {
          record: @course_module,
          signed_blob_id: @params[:signed_blob_id],
          profile: :module_cover_image
        }
      ).call
    rescue ArgumentError => error
      @course_module.errors.add(:module_cover_image_asset, error.message)
      nil
    end

    def attach_cover_image
      prepared_asset = @params[:prepared_asset]
      return @course_module if prepared_asset.blank?

      @repository.attach_asset(**prepared_asset)
    rescue StandardError => error
      @course_module.errors.add(:module_cover_image_asset, error.message)
      @course_module
    end
  end
end
