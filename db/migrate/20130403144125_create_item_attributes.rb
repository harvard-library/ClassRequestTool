class CreateItemAttributes < ActiveRecord::Migration
  def change
    create_table :item_attributes do |t|
      t.string :name, :null => false
      t.text :description
      t.timestamps
    end
    
    [:name, :description].each do|col|
      add_index :item_attributes, col
    end
    
    create_table(:item_attributes_rooms, :id => false) do|t|
      t.references :item_attribute
      t.references :room
    end
  end
end
