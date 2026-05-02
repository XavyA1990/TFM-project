class CourseModule < ApplicationRecord
  extend FriendlyId

  friendly_id :title, use: :slugged

  belongs_to :course

  has_many :lessons, dependent: :destroy

  has_one_attached :module_cover_image_asset

  enum :status, { draft: "draft", published: "published", archived: "archived" }

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: { scope: :course_id }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :status, presence: true

  private

  def should_generate_new_friendly_id?
    title_changed? || super
  end
end
