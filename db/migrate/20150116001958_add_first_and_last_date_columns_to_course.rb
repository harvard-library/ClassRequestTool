class AddFirstAndLastDateColumnsToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :first_date, :datetime, :index => true
    add_column :courses, :last_date, :datetime, :index => true
    
    add_index :courses, [:first_date, :last_date]
  end
end
