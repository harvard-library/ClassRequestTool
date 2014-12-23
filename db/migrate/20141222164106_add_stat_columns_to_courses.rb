class AddStatColumnsToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :session_count, :integer, index: true
    add_column :courses, :section_count, :integer, index: true
    add_column :courses, :total_attendance, :integer, index: true
    
    add_index :courses, [:session_count, :section_count, :total_attendance], :name => 'courses_index_sessions_sections_attendance'
  end
end
