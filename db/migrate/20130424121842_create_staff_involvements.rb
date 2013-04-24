class CreateStaffInvolvements < ActiveRecord::Migration
  def change
    create_table :staff_involvements do |t|
      t.string :involvement_text
      t.references :repository
      t.timestamps
    end
    
    add_index :staff_involvements, :involvement_text
  end
end
