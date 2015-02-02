class RemoveCanEditFromRepositoryTable < ActiveRecord::Migration
  def up
    remove_column :repositories, :can_edit
  end
  
  def down
    add_column :repositories, :can_edit, :boolean
  end
end
