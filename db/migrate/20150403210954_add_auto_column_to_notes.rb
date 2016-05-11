class AddAutoColumnToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :auto, :boolean, default: false, index: true
  end
end
