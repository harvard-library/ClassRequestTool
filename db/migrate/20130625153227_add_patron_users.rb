class AddPatronUsers < ActiveRecord::Migration
  def up
    add_column :users, :patron, :boolean, :default => true
  end

  def down
    remove_column :users, :patron
  end
end
