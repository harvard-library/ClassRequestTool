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
