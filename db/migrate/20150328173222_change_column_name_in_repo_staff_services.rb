class ChangeColumnNameInRepoStaffServices < ActiveRecord::Migration
  def change
    rename_column :repositories_staff_services, :staff_involvement_id, :staff_service_id
  end
end
