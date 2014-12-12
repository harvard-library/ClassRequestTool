class Admin::Notifications::NotificationController < ApplicationController

  # By default list links to all emails
  def action_missing(m, *args, &block)
  
    case (m)
      when 'assessment_received',
        @course = Assessment.last

      when 'assessment_requested',
        @course = Course.where(status: 'Closed').last

      when 'cancellation'
        @course = Course.where("status != 'Cancelled'").last

      when 'new_request_to_admin', 'new_request_to_requestor'
        @course = Course.where("status != 'Homeless'").last

      when 'uncancellation'
        @course = Course.where(status: 'Cancelled').last

      when 'repo_change', 'staff_change', 'timeframe_change'
        @course = Course.where(status: 'Scheduled, Claimed').last
        
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
    if ENV['NOTIFICATIONS_STATUS'] == 'ON'
      ENV['NOTIFICATIONS_STATUS'] = 'OFF'
    else
      ENV['NOTIFICATIONS_STATUS'] = 'ON'
    end
    
    render :text => ENV['NOTIFICATIONS_STATUS']
  end
end