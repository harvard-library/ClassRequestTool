class AddAndChangeColumnsForStaffServices < ActiveRecord::Migration
  def change
    rename_column :staff_services, :involvement_text, :description
    add_column    :staff_services, :required, :boolean
    add_column    :staff_services, :global, :boolean
  end
end
