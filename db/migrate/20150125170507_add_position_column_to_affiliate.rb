class AddPositionColumnToAffiliate < ActiveRecord::Migration
  def change
    add_column :affiliates, :position, :integer
    add_index :affiliates, :position
  end
end
