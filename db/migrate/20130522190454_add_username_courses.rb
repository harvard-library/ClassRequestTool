class AddUsernameCourses < ActiveRecord::Migration
  def up
    remove_column :courses, :contact_name
    add_column :courses, :contact_first_name, :string, :limit => 100
    add_column :courses, :contact_last_name, :string, :limit => 100
    add_column :courses, :contact_username, :string, :limit => 100
  end

  def down
    add_column :courses, :contact_name, :limit => 100, :null => false
    remove_column :courses, :contact_first_name
    remove_column :courses, :contact_last_name
    remove_column :courses, :contact_username
  end
end
