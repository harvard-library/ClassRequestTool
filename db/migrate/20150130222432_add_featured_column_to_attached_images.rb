class AddFeaturedColumnToAttachedImages < ActiveRecord::Migration
  def change
    add_column :attached_images, :featured, :boolean
    add_index :attached_images, :featured
  end
end
