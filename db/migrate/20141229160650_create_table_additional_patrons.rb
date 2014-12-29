class CreateTableAdditionalPatrons < ActiveRecord::Migration
  def change
    create_table :additional_patrons do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      
      t.references :course
      
      t.timestamps
    end
  end
end
