class SyllabusController < ApplicationController

  def download
    course_id = params[:course_id]
    # Get contact email for selected course
    contact_email = Course.where(:id => course_id).limit(1).pluck(:contact_email).first
    # Check if user is the requester
    is_user_requester = contact_email.to_s == current_user.email.to_s
    # Check if current user is either admin, staff, or the email matches contact email
    can_download = current_user.can_admin? || current_user.staff? || is_user_requester
    if can_download
      # Get syllabus from private directory
      basename = params[:basename]
      extension = params[:extension]
      download_path = "uploads/course/syllabus/#{course_id}/#{basename}.#{extension}"
      send_file download_path, :x_sendfile=>true
    else
      redirect_to('/') and return
    end
    
  end

end
