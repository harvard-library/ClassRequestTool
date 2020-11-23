class AddSchedulingIntroToCustomizations < ActiveRecord::Migration[5.2]
  def change
    add_column :customizations, :scheduling_intro, :text
  end
end
