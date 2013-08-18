class AddPrimaryContactCourses < ActiveRecord::Migration
  def up
    add_column :courses, :primary_contact_id, :integer
  end

  def down
    remove_column :courses, :primary_contact_id
  end
end
