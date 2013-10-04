class AddPinUsers < ActiveRecord::Migration
  def up
    add_column :users, :pinuser, :boolean, :default => false
  end

  def down
    remove_column :users, :pinuser
  end
  
end
