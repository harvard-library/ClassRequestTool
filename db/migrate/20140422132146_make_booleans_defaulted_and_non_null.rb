class MakeBooleansDefaultedAndNonNull < ActiveRecord::Migration
  @@user_cols = [:patron, :staff, :superadmin, :admin, :pinuser]
  def up
    @@user_cols.each do |col|
      change_column_null :users, col, false, false
    end

    change_column_null :notes, :staff_comment, false, false
    change_column_default :notes, :staff_comment, false

    change_column_null :repositories, :can_edit, false, false
    change_column_default :repositories, :can_edit, false

    change_column_null :emails, :message_sent, false, false
  end

  def down
    change_column_null :emails, :message_sent, true

    change_column_default :repositories, :can_edit, nil
    change_column_null :repositories, :can_edit, true

    change_column_default :notes, :staff_comment, nil
    change_column_null :notes, :staff_comment, true

    @@user_cols.reverse.each do |col|
      change_column_null :users, col, true
    end
  end
end
