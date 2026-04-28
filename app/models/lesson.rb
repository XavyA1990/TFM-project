class Lesson < ApplicationRecord
  extend FriendlyId

  friendly_id :title, use: :slugged

  belongs_to :course_module

  has_one_attached :lesson_content_asset

  enum status: { draft: "draft", published: "published", archived: "archived" }

  enum lesson_type: { text: "text", video: "video", pdf: "pdf", image: "image" }

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: { scope: :course_module_id }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :lesson_type, presence: true
  validates :status, presence: true

  private

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  def content_source
    return lesson_content_asset if lesson_content_asset.attached?
    return content_url if content_url.present?

    nil
  end
end