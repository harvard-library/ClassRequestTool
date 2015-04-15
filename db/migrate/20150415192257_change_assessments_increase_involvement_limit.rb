class ChangeAssessmentsIncreaseInvolvementLimit < ActiveRecord::Migration
  # The involvement column is currently implemented as a varchar(255),
  #   holding concatenated string values from the array Assessment::INVOLVEMENTS

  #   This is bad practice, and additionally has caused errors when combined selections
  #   are longer than 255 characters.

  #   So as not to silently impose this problem on future devs, changing to text rather
  #   than increasing column width.  A real solution would involve either normalization or
  #   postgres array types - but until such time as someone has time allotted to pursue
  #   a real solution, this will at least function.
  def up
    change_column :assessments, :involvement, :text
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new("text column `involvement` cannot be safely truncated to varchar(255).")
  end
end
