class RenameStaffInvolvements < ActiveRecord::Migration
  def up
    rename_table :staff_involvements, :staff_services
    rename_table :repositories_staff_involvements, :repositories_staff_services
  end

  def down
    rename_table :repositories_staff_services, :repositories_staff_involvements
    rename_table :staff_services, :staff_involvements
  end
end
