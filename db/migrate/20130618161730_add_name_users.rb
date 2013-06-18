class AddNameUsers < ActiveRecord::Migration
  def up
    add_column :users, :first_name, :string, :limit => 100
    add_column :users, :last_name, :string, :limit => 100
  end

  def down
    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end
