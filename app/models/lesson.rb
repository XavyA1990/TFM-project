class Lesson < ApplicationRecord
  CONTENT_TYPES_BY_LESSON_TYPE = {
    video: %w[video/mp4],
    pdf: %w[application/pdf],
    image: %w[image/png image/jpeg image/webp]
  }.freeze

  extend FriendlyId

  friendly_id :title, use: :slugged

  belongs_to :course_module

  has_one_attached :lesson_content_asset

  enum :status, { draft: "draft", published: "published", archived: "archived" }

  enum :lesson_type, { text: "text", video: "video", pdf: "pdf", image: "image" }

  before_validation :clear_body_for_non_text_lessons

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: { scope: :course_module_id }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :lesson_type, presence: true
  validates :status, presence: true
  validates :body, presence: true, if: :text?
  validate :attached_content_matches_lesson_type, if: :attachment_required?

  def self.allowed_content_types_for(lesson_type)
    CONTENT_TYPES_BY_LESSON_TYPE.fetch(lesson_type.to_sym, [])
  rescue NoMethodError
    []
  end

  def allowed_content_types
    self.class.allowed_content_types_for(lesson_type)
  end

  def attachment_required?
    !text?
  end

  def content_type_allowed_for_lesson_type?(content_type)
    allowed_content_types.include?(content_type)
  end

  def content_source
    return lesson_content_asset if lesson_content_asset.attached?
    nil
  end

  private

  def clear_body_for_non_text_lessons
    self.body = nil unless text?
  end

  def attached_content_matches_lesson_type
    return unless lesson_content_asset.attached?
    return if content_type_allowed_for_lesson_type?(lesson_content_asset.blob.content_type)

    errors.add(
      :lesson_content_asset,
      I18n.t("activerecord.errors.models.lesson.attributes.lesson_content_asset.invalid_for_type")
    )
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end
end
