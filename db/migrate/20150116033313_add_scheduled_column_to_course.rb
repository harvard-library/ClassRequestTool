class AddScheduledColumnToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :scheduled, :boolean
    add_index :courses, :scheduled
  end
end
