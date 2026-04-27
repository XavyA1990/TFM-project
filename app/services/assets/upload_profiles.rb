module Assets
  class UploadProfiles
    PROFILES = {
      avatar_image: {
        allowed_types: %w[image/png image/jpeg],
        max_size: 5.megabytes,
        attachment_name: :avatar_asset
      },
      tenant_logo: {
        allowed_types: %w[image/png image/jpeg image/webp],
        max_size: 5.megabytes,
        attachment_name: :logo_asset
      }
    }.freeze

    def self.fetch(profile)
      PROFILES[profile.to_sym] || raise(ArgumentError, "Unknown upload profile: #{profile}")
    end
  end
end
