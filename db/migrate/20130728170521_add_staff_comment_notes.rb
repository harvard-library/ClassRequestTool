class AddStaffCommentNotes < ActiveRecord::Migration
  def up
    add_column :notes, :staff_comment, :boolean, :default => false
  end

  def down
    remove_column :notes, :staff_comment
  end
end
