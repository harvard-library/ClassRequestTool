class ChangeCollaborationColumnToArray < ActiveRecord::Migration

  # NOTE: THIS MIGRATION DESTROYS DATA!
  # Since there are no courses in production that use this, we'll just destroy the column and remake
  def up
    remove_column :courses, :collaboration_options
    add_column :courses, :collaboration_options, :text, :array => true, :default => []
    remove_column :customizations, :collaboration_options
    add_column :customizations, :collaboration_options, :text, :array => true, :default => []
    puts "*** Remove 'serialize :collaboration_options' from models. ***"
  end
  
  def down
    remove_column :courses, :collaboration_options
    add_column :courses, :collaboration_options, :text
    remove_column :customizations, :collaboration_options
    add_column :customizations, :collaboration_options
    puts "*** Add 'serialize :collaboration_options' to models. ***"
  end
end
