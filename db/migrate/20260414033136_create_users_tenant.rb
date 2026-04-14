class CreateUsersTenant < ActiveRecord::Migration[8.1]
  def change
    create_table :users_tenants, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end

    add_index :users_tenants, [:user_id, :tenant_id], unique: true
  end
end
