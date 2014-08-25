class RemoveLocationIdFromRooms < ActiveRecord::Migration
  # Note: Irreversible migration.  This column refers to a detritus table,
  # which gets destroyed in the following migration
  def change
    remove_column :rooms, :location_id
  end
end
