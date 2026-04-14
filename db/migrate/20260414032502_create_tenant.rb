class CreateTenant < ActiveRecord::Migration[8.1]
  def change
    create_table :tenants, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.string :logo_url
      t.timestamps
    end
  end
end
