class Course < ApplicationRecord
  extend FriendlyId

  friendly_id :title, use: :slugged

  belongs_to :tenant

  has_many :course_modules, dependent: :destroy

  has_one_attached :course_cover_image_asset

  enum :status, { draft: "draft", published: "published", archived: "archived" }

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: { scope: :tenant_id }
  validates :status, presence: true

  def course_cover_image_source
    return course_cover_image_asset if course_cover_image_asset.attached?
    return cover_image_url if cover_image_url.present?

    nil
  end

  private

  def should_generate_new_friendly_id?
    title_changed? || super
  end
end