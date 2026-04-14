class CreateUserTenantRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :user_tenant_roles, id: :uuid do |t|
      t.references :users_tenant, null: false, foreign_key: true, type: :uuid
      t.references :role, null: false, foreign_key: true, type: :uuid
      t.string :scope_type, null: false, default: "selected_courses"
      t.timestamps
    end

    add_index :user_tenant_roles, [:users_tenant_id, :role_id], unique: true
  end
end
