class AddTableAttachedImages < ActiveRecord::Migration
  def change
    create_table :attached_images do |t|
      
      t.string      :image
      t.string      :caption
      t.references  :picture, polymorphic: true     # Set up polymorphic association - creates type and ID columns
      
      t.timestamps
      
    end
    
    add_index :attached_images, [:picture_id, :picture_type]
    
  end
end
