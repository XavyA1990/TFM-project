class CreateTenant < ActiveRecord::Migration[8.1]
  def change
    create_table :tenants, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.string :logo_url
      t.string :description
      t.string :header_text
      t.string :subheader_text
      t.timestamps
    end
  end
end
