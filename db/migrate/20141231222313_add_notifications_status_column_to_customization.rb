class AddNotificationsStatusColumnToCustomization < ActiveRecord::Migration
  def change
    add_column :customizations, :notifications_on, :boolean
  end
end
