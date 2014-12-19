class AddColumnToCustomization < ActiveRecord::Migration
  def change
    add_column :customizations, :slogan, :string
    
    custom = Customization.last
    custom.slogan = "Insert your slogan here"
    custom.save
  end
end
