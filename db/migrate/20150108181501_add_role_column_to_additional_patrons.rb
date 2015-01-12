class AddRoleColumnToAdditionalPatrons < ActiveRecord::Migration
  def change
    add_column :additional_patrons, :role, :string
  end
end
