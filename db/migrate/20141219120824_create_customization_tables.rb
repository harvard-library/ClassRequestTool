class CreateCustomizationTables < ActiveRecord::Migration
  class Customization < ActiveRecord::Base
    # Guard class to prevent issues on migrate
  end

  def change
    create_table :customizations do |t|
      t.string :institution
      t.string :institution_long
      t.string :tool_name
      t.string :tool_tech_admin_name
      t.string :tool_tech_admin_email
      t.string :tool_content_admin_name
      t.string :tool_content_admin_email
      t.string :default_email_sender
      
      t.timestamps
    end
    
    create_table :affiliates do |t|
      t.string      :name
      t.string      :url
      t.text        :description
      t.references  :customization
    
      t.timestamps
    end
    
    Customization.reset_column_information!
    
    # Initialize
    Customization.create  institution:              'Academia',
                          institution_long:         'Academia University',
                          tool_name:                'Class Request Tool',
                          tool_tech_admin_name:     'Technical Contact',
                          tool_tech_admin_email:    'tech@academia.edu',
                          tool_content_admin_name:  'Content Contact',
                          tool_content_admin_email: 'librarian@academia.edu',
                          default_email_sender:     'library_crt@academia.edu'
  end
end
