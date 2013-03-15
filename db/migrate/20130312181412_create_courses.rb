class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :title
      t.string :subject
      t.string :course_number
      t.string :affiliation
      t.string :contact_name, :limit => 100, :null => false
      t.string :contact_email, :limit => 150, :null => false
      t.string :contact_phone, :limit => 25, :null => false
      t.datetime :pre_class_appt
      t.datetime :timeframe
      t.references :repository
      t.references :room
      t.text :staff_involvement
      t.string :status
      t.string :file
      t.timestamps
    end
    
    [:title, :subject, :course_number, :affiliation, :contact_name, :contact_email, :contact_phone, :pre_class_appt, :timeframe, :staff_involvement, :status].each do|col|
      add_index :courses, col
    end
    
    create_table(:courses_users, :id => false) do|t|
      t.references :course
      t.references :user
    end
  end
end
