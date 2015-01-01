class Admin::Notifications::NotificationController < Admin::AdminController

  # By default list links to all emails
  def action_missing(m, *args, &block)
  
    case (m)
      when 'assessment_received_to_admins'
        @assessment = Assessment.last

      when 'assessment_received_to_users'
        @assessment = Assessment.last

      when 'assessment_requested'
        @course = Course.where(status: 'Closed').last

      when 'cancellation'
        @course = Course.where("status != 'Cancelled'").last

      when 'new_request_to_admin', 'new_request_to_requestor'
        @course = Course.where("status != 'Homeless'").last

      when 'uncancellation'
        @course = Course.where(status: 'Cancelled').last

      when 'repo_change', 'staff_change', 'timeframe_change'
        @course = Course.where(status: 'Active').last
        
      when 'new_note'
        @note = Note.new(:staff_comment => false, :note_text => 'I have something to say about this!')
                
      else
        all_notifications = 'admin/notifications/all_notifications'
    end
    
    if all_notifications.nil?
      render :file => "notification/#{m}", :layout => 'notification_preview'
    else
      render :file => all_notifications
    end
  end
  
  def toggle_notifications
    if $local_config.notifications_on?
      $local_config.notifications_on = false
      status = 'OFF'
      Rails.configuration.action_mailer.perform_deliveries = false
    else  
      $local_config.notifications_on = true
      status = 'ON'      
      Rails.configuration.action_mailer.perform_deliveries = true
      # If any jobs are in the queue, send them
      Delayed::Job.all.each do |job|
        if job.run_at < Time.now
          job.run_at = Time.now
          job.last_error = nil
          job.failed_at = nil
          job.save!
        end
      end
    end
    
    if $local_config.save
      render :text => status
    else
      render :nothing
    end
  end
end