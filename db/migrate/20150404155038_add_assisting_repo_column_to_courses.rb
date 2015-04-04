class AddAssistingRepoColumnToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :assisting_repository_id, :integer, index: true
  end
end
