class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :name
      t.text :description
      t.string :url
      t.references :repository

      t.timestamps
    end
    add_index :collections, :repository_id
  end
end
