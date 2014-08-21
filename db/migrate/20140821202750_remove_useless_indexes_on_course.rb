class RemoveUselessIndexesOnCourse < ActiveRecord::Migration
  COLS = [:comments, :external_syllabus, :goal]
  def up
    COLS.each do |col|
      remove_index :courses, col
    end
  end

  def down
    COLS.reverse.each do |col|
      add_index :courses, col
    end
  end
end
