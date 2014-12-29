class CorrectSessionCountColumnType < ActiveRecord::Migration
  def up
    change_column :courses, :session_count, :integer
  end

  def down
    change_column :courses, :session_count, :string
  end
end
