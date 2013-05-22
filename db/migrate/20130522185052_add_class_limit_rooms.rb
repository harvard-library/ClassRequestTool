class AddClassLimitRooms < ActiveRecord::Migration
  def up
    add_column :rooms, :class_limit, :integer, :default => 0
  end

  def down
    remove_column :rooms, :class_limit
  end
end
