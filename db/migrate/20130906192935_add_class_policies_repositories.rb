class AddClassPoliciesRepositories < ActiveRecord::Migration
  def up
    add_column :repositories, :class_policies, :text
  end

  def down
    remove_column :repositories, :class_policies
  end
end
