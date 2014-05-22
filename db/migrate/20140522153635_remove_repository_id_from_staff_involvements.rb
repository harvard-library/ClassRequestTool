class RemoveRepositoryIdFromStaffInvolvements < ActiveRecord::Migration
  def up 
    remove_column :staff_involvements, :repository_id
  end

  def down
    add_column :staff_involvements, :repository_id, :integer
  end
end
