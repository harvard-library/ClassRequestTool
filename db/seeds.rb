# Basic file for seeding the database

# Create a default superadmin user
User.create(
  :username               => 'superadmin',
  :password               => 'password',
  :password_confirmation  => 'password',
  :email                  => 'superadmin@example.edu',
  :first_name             => 'Super',
  :last_name              => 'Admin',
  :superadmin             => true
)

# Create a default admin user
User.create(
  :username               => 'admin',
  :password               => 'password',
  :password_confirmation  => 'password',
  :email                  => 'admin@example.edu',
  :first_name             => 'Merely',
  :last_name              => 'Admin',
  :admin                  => true
)

# Create a basic customization - this should be changed and a banner added
Admin::Customization.create(
  :institution              => 'Harvard',
  :institution_long         => 'Harvard University',
  :tool_name                => 'Class Request Tool',
  :slogan                   => 'We have what you want to see',
  :tool_tech_admin_name     => 'Penelope Infotech',
  :tool_tech_admin_email    => 'infotech@example.edu',
  :tool_content_admin_name  => 'Percival Content-Guru',
  :tool_content_admin_email => 'content_admin@example.edu',
  :default_email_sender     => 'library@example.edu',
  :notifications_on         => false,
  :collaboration_options    => [
    'Share planning and selection responsibilities',
    'Share instructional responsibilities',
    'Share materials'
  ]
  
)

# Custom text which is inserted into notification emails. See the notification previews.  
custom_notification_texts = {
  'assessment_received_to_admins' => '<p>Replace custom text here or delete</p>',
  'assessment_received_to_users'  => '<p>Replace custom text here or delete</p>',
  'assessment_requested'          => '<p>Replace custom text here or delete</p>',
  'cancellation'                  => '<p>Replace custom text here or delete</p>',
  'homeless_courses_reminder'     => '<p>Replace custom text here or delete</p>',
  'new_note'                      => '<p>Replace custom text here or delete</p>',
  'new_request_to_admin'          => '<p>Replace custom text here or delete</p>', 
  'new_request_to_requestor'      => '<p>Replace custom text here or delete</p>',
  'uncancellation'                => '<p>Replace custom text here or delete</p>',
  'repo_change'                   => '<p>Replace custom text here or delete</p>', 
  'staff_change'                  => '<p>Replace custom text here or delete</p>', 
  'timeframe_change'              => '<p>Replace custom text here or delete</p>',
}

custom_notification_texts.each do |k, v|
  Admin::CustomText.create( key: k, text: v )
end
