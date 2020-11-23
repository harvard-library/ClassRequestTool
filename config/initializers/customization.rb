# set up the default Customization
if File.exists? File.join(Rails.root, 'config', 'customization.yml')
  ::Customization::DEFAULTS = Rails.application.config_for(:customization)
else
  ::Customization::DEFAULTS = { institution: 'Academia',
      institution_long:         'Academia University',
      tool_name:                'Class Request Tool',
      tool_tech_admin_name:     'Technical Contact',
      tool_tech_admin_email:    'tech@academia.edu',
      tool_content_admin_name:  'Content Contact',
      tool_content_admin_email: 'librarian@academia.edu',
      default_email_sender:     'library_crt@academia.edu',
      scheduling_intro:         <<~HTML
                                  <p>Depending on your teaching needs and class size, we offer the following options:
                                  <ul>
                                    <li>Single class sessions (most common request)</li>
                                    <li>Multiple class sessions (bring a class more than once a semester</li>
                                    <li>Multiple sections (for large classes that exceed room capacity)</li></ul>
                                  <p>Please enter your preferred date and time for each class visit. If your only options for scheduling fall
                                  outside normal business hours, please use the note field to detail your availability.</p>
                                  <p>Final scheduling of a class visit is subject to both room and staff availability.</p>
                                HTML
 }
end
