class CreateLesson < ActiveRecord::Migration[8.1]
  def change
    create_table :lessons, id: :uuid do |t|
      t.references :course_module, null: false, foreign_key: true, type: :uuid

      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      t.string :lesson_type, null: false
      t.string :content_url
      t.string :status, null: false, default: "draft"
      t.text :body

      t.timestamps
    end

    add_index :lessons, [:course_module_id, :slug], unique: true
    add_index :lessons, [:course_module_id, :position]
    add_index :lessons, [:course_module_id, :status]
  end
end
