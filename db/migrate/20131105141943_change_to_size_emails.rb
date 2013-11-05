class ChangeToSizeEmails < ActiveRecord::Migration
  def up
    change_column :emails, :to, :text
  end

  def down
    change_column :emails, :to, :string
  end
end
