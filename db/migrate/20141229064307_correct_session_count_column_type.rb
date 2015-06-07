class CorrectSessionCountColumnType < ActiveRecord::Migration
  def up
    connection.execute(%q{
      ALTER TABLE COURSES
      ALTER COLUMN session_count
      type integer using cast(session_count as integer)
    })
  end

  def down
    change_column :courses, :session_count, :string
  end
end
