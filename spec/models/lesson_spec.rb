require "rails_helper"

RSpec.describe Lesson, type: :model do
  subject(:lesson) { build(:lesson) }

  describe "validations" do
    it "builds a valid text lesson from the factory" do
      expect(lesson).to be_valid
    end

    it "requires body content for text lessons" do
      lesson.body = nil

      expect(lesson).not_to be_valid
      expect(lesson.errors[:body]).to include(I18n.t("errors.messages.blank"))
    end

    it "clears body when the lesson type is not text" do
      lesson.lesson_type = :video

      lesson.valid?

      expect(lesson.body).to be_nil
    end

    it "accepts an attachment that matches the lesson type" do
      lesson.lesson_type = :image
      lesson.lesson_content_asset.attach(
        io: StringIO.new("fake image"),
        filename: "cover.png",
        content_type: "image/png"
      )

      expect(lesson).to be_valid
    end

    it "rejects an attachment that does not match the lesson type" do
      lesson.lesson_type = :image
      lesson.lesson_content_asset.attach(
        io: StringIO.new("%PDF-1.4"),
        filename: "lesson.pdf",
        content_type: "application/pdf"
      )

      expect(lesson).not_to be_valid
      expect(lesson.errors[:lesson_content_asset]).to include(
        I18n.t("activerecord.errors.models.lesson.attributes.lesson_content_asset.invalid_for_type")
      )
    end
  end
end
