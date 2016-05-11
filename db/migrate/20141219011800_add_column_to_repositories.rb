class AddColumnToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :email_details, :text
  end
end
