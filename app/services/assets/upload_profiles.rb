module Assets
  class UploadProfiles
    PROFILES = {
      avatar_image: {
        allowed_types: %w[image/png image/jpeg image/webp],
        max_size: 5.megabytes,
        attachment_name: :avatar_asset
      },
      tenant_logo: {
        allowed_types: %w[image/png image/jpeg image/webp],
        max_size: 5.megabytes,
        attachment_name: :logo_asset
      },
      course_cover_image: {
        allowed_types: %w[image/png image/jpeg image/webp],
        max_size: 10.megabytes,
        attachment_name: :course_cover_image_asset
      },
      module_cover_image: {
        allowed_types: %w[image/png image/jpeg image/webp],
        max_size: 10.megabytes,
        attachment_name: :module_cover_image_asset
      },
      lesson_content: {
        allowed_types: %w[image/png image/jpeg image/webp video/mp4 application/pdf],
        max_size: 50.megabytes,
        attachment_name: :lesson_content_asset
      }
    }.freeze

    def self.fetch(profile)
      PROFILES[profile.to_sym] || raise(ArgumentError, "Unknown upload profile: #{profile}")
    end
  end
end
