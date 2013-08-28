class AddMultiSessionDatesCourses < ActiveRecord::Migration
  def up
    add_column :courses, :timeframe_2, :datetime
    add_column :courses, :timeframe_3, :datetime
    add_column :courses, :timeframe_4, :datetime
  end

  def down
    remove_column :courses, :timeframe_2
    remove_column :courses, :timeframe_3
    remove_column :courses, :timeframe_4
  end
end
