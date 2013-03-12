class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :title
      t.datetime :pre_class_appt
      t.datetime :timeframe
      t.references :user
      t.references :repository
      t.references :room
      t.text :staff_involvement
      t.string :status
      t.timestamps
    end
    
    [:title, :pre_class_appt, :timeframe, :staff_involvement, :status].each do|col|
      add_index :courses, col
    end
    
    create_table(:courses_users, :id => false) do|t|
      t.references :course
      t.references :user
    end
  end
end
