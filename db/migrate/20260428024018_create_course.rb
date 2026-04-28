class CreateCourse < ActiveRecord::Migration[8.1]
  def change
    create_table :courses, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid

      t.string :title, null: false
      t.string :slug, null: false
      t.string :cover_image_url
      t.string :short_description
      t.text :description
      t.string :status, null: false, default: "draft"

      t.timestamps
    end

    add_index :courses, [:tenant_id, :slug], unique: true
    add_index :courses, [:tenant_id, :status]
  end
end
