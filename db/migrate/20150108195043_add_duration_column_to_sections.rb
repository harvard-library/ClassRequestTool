class AddDurationColumnToSections < ActiveRecord::Migration
  def change
    add_column :sections, :session_duration, :integer
    add_index :sections, :session_duration
  end
end
