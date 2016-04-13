class AddIndexesToItemAttributesJoins < ActiveRecord::Migration
# this "unique-ifies" the records of the join tables of item_attributes
# the dedup method assumes postgres sql
  def change
    reversible do |dir|
      dir.up do
        dedup("item_attributes_repositories")
        dedup("item_attributes_rooms")
      end
      dir.down do
        # do nothing
      end
    end
    add_index :item_attributes_repositories, [:item_attribute_id, :repository_id], :unique => true, 
      :name => 'index_item_attributes_repositories_on_join'
    add_index :item_attributes_rooms,  [:item_attribute_id, :room_id], :unique => true,
      :name => 'index_item_attributes_rooms_on_join'
  end
  def dedup(table_name)
    execute <<-SQL
          DELETE FROM #{table_name}  WHERE ctid NOT IN
             (SELECT MAX(ctid) FROM  #{table_name} GROUP BY #{table_name}.*);
    SQL
  end
end
