class AddStaffUsers < ActiveRecord::Migration
  def up
    add_column :users, :staff, :boolean, :default => false
  end

  def down
    remove_column :users, :staff
  end
end
