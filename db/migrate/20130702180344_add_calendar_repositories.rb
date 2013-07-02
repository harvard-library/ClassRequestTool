class AddCalendarRepositories < ActiveRecord::Migration
  def up
    add_column :repositories, :calendar, :text
  end

  def down
    remove_column :repositories, :calendar
  end
end
