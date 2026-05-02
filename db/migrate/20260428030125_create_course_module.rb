class CreateCourseModule < ActiveRecord::Migration[8.1]
  def change
    create_table :course_modules, id: :uuid do |t|
      t.references :course, null: false, foreign_key: true, type: :uuid

      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :position, null: false, default: 1
      t.string :status, null: false, default: "draft"

      t.timestamps
    end

    add_index :course_modules, [:course_id, :slug], unique: true
    add_index :course_modules, [:course_id, :position]
    add_index :course_modules, [:course_id, :status]
  end
end
