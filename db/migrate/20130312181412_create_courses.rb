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
      t.datetime :pre_class_appt_choice_1
      t.datetime :pre_class_appt_choice_2
      t.datetime :pre_class_appt_choice_3
      t.datetime :timeframe
      t.datetime :time_choice_1
      t.datetime :time_choice_2
      t.datetime :time_choice_3
      t.datetime :time_choice_4
      t.references :repository
      t.references :room
      t.text :staff_involvement
      t.integer :number_of_students
      t.string :status
      t.string :file
      t.string :external_syllabus
      t.string :duration
      t.text :comments
      t.string :course_sessions
      t.string :session_count
      t.text :goal
      t.string :instruction_session
      t.timestamps
    end
    
    [:title, :subject, :course_number, :affiliation, :contact_name, :contact_email, :contact_phone, :pre_class_appt, :timeframe, :staff_involvement, :status, :external_syllabus, :duration, :comments, :course_sessions, :session_count, :goal, :instruction_session].each do|col|
      add_index :courses, col
    end
    
    create_table(:courses_users, :id => false) do|t|
      t.references :course
      t.references :user
    end
    
    create_table(:courses_item_attributes, :id => false) do|t|
      t.references :item_attribute
      t.references :course
    end
    
    create_table(:courses_staff_involvements, :id => false) do|t|
      t.references :course
      t.references :staff_involvement
    end
  end
end
