class AddWelcomeToCustomizations < ActiveRecord::Migration
  def change
    add_column :customizations, :welcome, :text
  end
end
