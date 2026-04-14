class CreatePermissions < ActiveRecord::Migration[8.1]
  def change
    create_table :permissions, id: :uuid do |t|
      t.string :name, null: false
      t.string :action, null: false
      t.string :subject_class, null: false
      t.string :description
      t.timestamps
    end
  end
end
