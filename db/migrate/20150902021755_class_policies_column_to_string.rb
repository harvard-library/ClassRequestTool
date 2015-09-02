class ClassPoliciesColumnToString < ActiveRecord::Migration
  def change
    change_column :repositories, :class_policies, :string
  end
end
