class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.references :location
      t.timestamps
    end
    
    add_index :rooms, :name
  end
end
