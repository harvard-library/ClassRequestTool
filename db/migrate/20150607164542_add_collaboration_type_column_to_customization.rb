class AddCollaborationTypeColumnToCustomization < ActiveRecord::Migration
  def change
    add_column :customizations, :collaboration_options, :text
  end
end
