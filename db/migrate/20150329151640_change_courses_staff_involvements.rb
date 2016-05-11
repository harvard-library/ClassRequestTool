class ChangeCoursesStaffInvolvements < ActiveRecord::Migration
  def up
    rename_table  :courses_staff_involvements, :courses_staff_services
    rename_column :courses_staff_services, :staff_involvement_id, :staff_service_id
  end

  def down
    rename_column :courses_staff_services, :staff_service_id, :staff_involvement_id
    rename_table  :courses_staff_services, :courses_staff_involvements
  end
end
