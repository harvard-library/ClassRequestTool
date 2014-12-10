class Admin::Notifications::NotificationController < ApplicationController

  # By default list links to all emails
  def action_missing(m, *args, &block)
  
    case (m)
      when :assessment
        @course = Course.where(status: 'Closed').last
        render :file => 'notification/assessment', :layout => 'notification_preview'

      when :cancellation
        @course = Course.where("status != 'Cancelled'").last
        render :file => 'notification/cancellation', :layout => 'notification_preview'

      when :new_request_to_admin
        @course = Course.where("status != 'Homeless'").last
        render :file => 'notification/new_request_to_admin', :layout => 'notification_preview'

      when :new_request_to_requestor
        @course = Course.where("status != 'Homeless'").last
        render :file => 'notification/new_request_to_requestor', :layout => 'notification_preview'

      when :repo_change
        @course = Course.where(status: 'Scheduled, Claimed').last
        render :file => 'notification/repo_change', :layout => 'notification_preview'

      when :staff_change
        @course = Course.where(status: 'Scheduled, Claimed').last
        render :file => 'notification/staff_change', :layout => 'notification_preview'

      when :timeframe_change
        @course = Course.where(status: 'Scheduled, Claimed').last
        render :file => 'notification/timeframe_change', :layout => 'notification_preview'

      when :uncancellation
        @course = Course.where(status: 'Cancelled').last
        render :file => 'notification/uncancellation', :layout => 'notification_preview'
        
      else
        render :file => 'admin/notifications/all_notifications'

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