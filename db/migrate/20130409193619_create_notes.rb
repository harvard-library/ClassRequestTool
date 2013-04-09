class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.text :note_text, :null => false
      t.references :user, :null => false
      t.references :course, :null => false
      t.timestamps
    end
    
    add_index :notes, :note_text
  end
end
