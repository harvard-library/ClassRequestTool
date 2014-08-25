class DropLocations < ActiveRecord::Migration
  # Irreversible migration: drop detritus table "locations"
  def change
    drop_table :locations
  end
end
