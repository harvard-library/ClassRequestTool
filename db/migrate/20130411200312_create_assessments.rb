class CreateAssessments < ActiveRecord::Migration
  def change
    create_table :assessments do |t|
      t.text :using_materials
      t.string :involvement
      t.integer :staff_experience
      t.integer :staff_availability
      t.integer :space
      t.integer :request_course
      t.integer :request_materials
      t.integer :catalogs
      t.integer :digital_collections
      t.string :involve_again
      t.text :not_involve_again
      t.text :better_future
      t.text :comments
      t.references :course
      t.timestamps
    end
    
    [:using_materials, :involvement, :staff_experience, :staff_availability, :space, :request_course, :request_materials, :catalogs, :digital_collections, :involve_again, :not_involve_again, :better_future].each do|col|
      add_index :assessments, col
    end
  end
end
