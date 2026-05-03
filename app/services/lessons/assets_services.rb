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
      return purge_content if @action == :purge_content

      raise ArgumentError, I18n.t("services.errors.invalid_action")
    end

    private

    def prepare_content
      prepared_asset = @ingestion_service.new(
        :prepare,
        {
          record: @lesson,
          signed_blob_id: @params[:signed_blob_id],
          profile: :lesson_content
        }
      ).call

      validate_prepared_content_matches_lesson_type!(prepared_asset[:blob])

      prepared_asset
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

    def purge_content
      @repository.purge_asset(record: @lesson, attachment_name: :lesson_content_asset)
      @lesson
    rescue StandardError => error
      @lesson.errors.add(:lesson_content_asset, error.message)
      @lesson
    end

    def validate_prepared_content_matches_lesson_type!(blob)
      if @lesson.text?
        raise ArgumentError, I18n.t("activerecord.errors.models.lesson.attributes.lesson_content_asset.not_allowed_for_text")
      end

      return if @lesson.content_type_allowed_for_lesson_type?(blob.content_type)

      raise ArgumentError, I18n.t("activerecord.errors.models.lesson.attributes.lesson_content_asset.invalid_for_type")
    end
  end
end
