class AddLandingPageRepositories < ActiveRecord::Migration
  def up
    add_column :repositories, :landing_page, :string
  end

  def down
    remove_column :repositories, :landing_page
  end
end
