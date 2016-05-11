class ChangeColumnFileInCoursesToSyllabus < ActiveRecord::Migration
  def up
    rename_column :courses, :file, :syllabus
  end

  def down
    rename_column :courses, :syllabus, :file
  end
end
