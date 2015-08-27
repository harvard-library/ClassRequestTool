class AddHomelessOptionsToCustomization < ActiveRecord::Migration
  def change
    add_column :customizations, :homeless_staff_services, :integer, :array => true, :default => []
    add_column :customizations, :homeless_technologies, :integer, :array => true, :default => []
  end
end
