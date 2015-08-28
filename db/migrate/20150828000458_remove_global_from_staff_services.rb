class RemoveGlobalFromStaffServices < ActiveRecord::Migration
  def change
    remove_column :staff_services, :global
  end
end
