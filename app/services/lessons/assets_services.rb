module Lessons
  class AssetsServices
    def initialize(action, params, ingestion_service: Assets::IngestionServices, repository: AssetsRepository)
      @action = action
      @params = params
      @ingestion_service = ingestion_service
      @repository = repository
      @lesson = params[:lesson]
    end

    def call
      return prepare_content if @action == :prepare_content
      return attach_content if @action == :attach_content

      raise ArgumentError, "Invalid action"
    end

    private

    def prepare_content
      @ingestion_service.new(
        :prepare,
        {
          record: @lesson,
          signed_blob_id: @params[:signed_blob_id],
          profile: :lesson_content
        }
      ).call
    rescue ArgumentError => error
      @lesson.errors.add(:lesson_content_asset, error.message)
      nil
    end

    def attach_content
      prepared_asset = @params[:prepared_asset]
      return @lesson if prepared_asset.blank?

      @repository.attach_asset(**prepared_asset)
    rescue StandardError => error
      @lesson.errors.add(:lesson_content_asset, error.message)
      @lesson
    end
  end
end
