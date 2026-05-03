class RemoveUnusedUrls < ActiveRecord::Migration[8.1]
  def change
    remove_column :tenants, :logo_url, :string
    remove_column :courses, :cover_image_url, :string
    remove_column :lessons, :content_url, :string
    remove_column :users, :avatar_url, :string
  end
end
