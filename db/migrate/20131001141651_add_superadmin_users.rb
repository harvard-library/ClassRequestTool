class AddSuperadminUsers < ActiveRecord::Migration
  def up
    add_column :users, :superadmin, :boolean, :default => false
  end

  def down
    remove_column :users, :superadmin
  end
end
