class RemoveCustomizationRefFromAffiliates < ActiveRecord::Migration
  def change
    remove_reference :affiliates, :customization
  end
end
