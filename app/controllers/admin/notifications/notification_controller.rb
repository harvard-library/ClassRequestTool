class Admin::Notifications::NotificationController < ApplicationController
  def assessment()
    @course = Course.where(status: 'Closed').last
    render :file => 'notification/assessment', :layout => 'notification'
  end
  
  def cancellation()
    @course = Course.where("status != 'Cancelled'").last
    render :file => 'notification/cancellation', :layout => 'notification'
  end
  
  def new_request_to_admin()
    @course = Course.where("status != 'Homeless'").last
    render :file => 'notification/new_request_to_admin', :layout => 'notification'
  end
  
  def new_request_to_requestor()
    @course = Course.where("status != 'Homeless'").last
    render :file => 'notification/new_request_to_requestor', :layout => 'notification'
  end
  
  def repo_change()
    @course = Course.where(status: 'Scheduled, Claimed').last
    render :file => 'notification/repo_change', :layout => 'notification'
  end
  
  def staff_change()
    @course = Course.where(status: 'Scheduled, Claimed').last
    render :file => 'notification/staff_change', :layout => 'notification'
  end
  
  def timeframe_change()
    @course = Course.where(status: 'Scheduled, Claimed').last
    render :file => 'notification/timeframe_change', :layout => 'notification'
  end
  
  def uncancellation()
    @course = Course.where(status: 'Cancelled').last
    render :file => 'notification/uncancellation', :layout => 'notification'
  end
end