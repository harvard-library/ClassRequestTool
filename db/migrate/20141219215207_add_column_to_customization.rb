class AddColumnToCustomization < ActiveRecord::Migration
  class Customization < ActiveRecord::Base
    # Guard class to avoid validation errors
  end

  def change
    add_column :customizations, :slogan, :string
    
    custom = Customization.last
    custom.slogan = "Insert your slogan here"
    custom.save
  end
end
