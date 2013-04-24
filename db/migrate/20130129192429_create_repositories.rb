class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :name
      t.text :description
      t.integer :class_limit, :default => 0
      t.references :user
      t.boolean :can_edit
      t.timestamps
    end
    
    [:name, :description, :class_limit, :can_edit].each do|col|
      add_index :repositories, col
    end
    
    create_table(:repositories_rooms, :id => false) do|t|
      t.references :repository
      t.references :room
    end
    
    create_table(:repositories_users, :id => false) do|t|
      t.references :repository
      t.references :user
    end
    
    create_table(:repositories_staff_involvements, :id => false) do|t|
      t.references :repository
      t.references :staff_involvement
    end
  end
end
