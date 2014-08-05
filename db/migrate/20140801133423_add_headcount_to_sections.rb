class AddHeadcountToSections < ActiveRecord::Migration
  def change
    add_column :sections, :headcount, :integer
  end
end
