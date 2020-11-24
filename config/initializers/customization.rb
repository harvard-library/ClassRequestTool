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
                                  <p>Depending on your needs, we can work with your class in a single session, multiple visits, or entirely asynchronously. Please enter your preferred date and time for each synchronous class visit. For asynchronous classes, enter the approximate date and time the relevant activity/assignment would become available to students.</p>
                                  <p>We may reach out to you for alternative dates depending on staff availability and your class’s collection needs. If your class visit times fall outside normal business hours, please use the note field to detail your availability.</p>
                                HTML
 }
end
