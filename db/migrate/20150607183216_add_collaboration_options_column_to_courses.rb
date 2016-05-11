class AddCollaborationOptionsColumnToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :collaboration_options, :text
  end
end
