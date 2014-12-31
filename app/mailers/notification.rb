class Notification < ActionMailer::Base

  include  AbstractController::Callbacks    # Includes the after_filter

  default from: DEFAULT_MAILER_SENDER
  
  after_filter :deliver_notifications
  
  def assessment_received_to_admins(assessment)
    @assessment = assessment
    
    # Sends to all tool admins
    recipients = User.where('superadmin = ? OR admin = ?', true, true).map{|a| a.email}
    mail(to: recipients, subject: "[ClassRequestTool] Class Assessment Received")
  end

  def assessment_received_to_users(assessment)
    @assessment = assessment
    
    # Sends to assigned staff
    recipients = @assessment.course.users.map{|u| u.email }

    # Sends to primary staff contact(s)
    unless @assessment.course.primary_contact.blank?
      recipients << @assessment.course.primary_contact.email
    end    
    mail(to: recipients, subject: "[ClassRequestTool] Class Assessment Received")
  end

  def assessment_requested(course)
    @course = course

    # send email to requester and additional contacts
    recipients = [course.contact_email]
    
    unless course.additional_patrons.blank?
      recipients += course.additional_patrons.map { |p| p.email }
    end
   
    mail(to: recipients, subject: "[ClassRequestTool] Please Assess your Recent Class at #{course.repo_name}")
  end
  
  def cancellation(course)
    @course = course

    # Send to primary staff contact, if exists, and to first staff contact with email    
    recipients = Array.new
    unless course.primary_contact.blank?
      recipients << course.primary_contact.email
    end
    unless course.users.nil?
      course.users.each do |user|
        unless user.email.blank?
          recipients << user.email
          break
        end
      end
    end
    
    # Send email
    mail(to: recipients, subject: "[ClassRequestTool] Class cancellation confirmation")
  end
  
  def homeless_courses_reminder
    @courses = Course.where("repository_id IS NULL AND created_at <= ?", Time.now - 2.days)
    admins = User.where('admin = ? OR superadmin = ?', true, true).pluck(:email)
    
    mail(to: admins, subject: "[ClassRequestTool] Homeless classes are languishing!")
  end
  
  def new_note(note, current_user)
    @note = note
    @course = @note.course
    repository = @note.course.repo_name
    
    recipients = []
    
    # Send to all admins and repository staff if there are no repository contacts
    if @note.course.primary_contact.blank? && @note.course.users.blank?
      recipients += User.where('admin = ? OR superadmin = ?', true, true).map{|u| u.email }
      unless @note.course.repository.nil?
        recipients += @note.course.repository.users.map{|u| u.email}
      end
    
    # Otherwise send to all users assigned to course
    else
      recipients += @note.course.users.map{|u| u.email}

      unless @note.course.primary_contact.blank?
        recipients << @note.course.primary_contact.email
      end
    end
    
    # If it's not a comment for staff, send to the patron, too
    unless @note.staff_comment
      recipients << @note.course.contact_email
      unless @note.course.additional_patrons.blank?
        recipients += @note.course.additional_patrons.map { |p| p.email }
      end
    end
    
    # Remove the current user's email
    recipients -= [current_user.email]
       
    mail(to: recipients, subject: "[ClassRequestTool] A Comment has been Added to a Class")
  end

  def new_request_to_requestor(course)
    @course = course
       
    # send email to requester
    recipients = [course.contact_email]
    unless course.additional_patrons.blank?
      recipients += course.additional_patrons.map { |p| p.email }
    end
    mail(to: recipients, subject: "[ClassRequestTool] Class Request Successfully Submitted for #{course.title}")
  end
  
  def new_request_to_admin(course)
    @course = course
    
    # If repository is empty (homeless), send to all admins of tool
    if course.repository.blank?
      recipients = User.where('admin = ? OR superadmin = ?', true, true).map{|a| a.email }

    # Otherwise send to all users assigned to the repository
    else
      recipients = course.repository.users.map{|u| u.email}
      superadmins = User.where(:superadmin => true).map{|u| u.email}
      recipients += superadmins
    end
    
    mail(to: recipients, subject: "[ClassRequestTool] A New #{course.repository.blank? ? 'Homeless ' : ''}Class Request has been Received")
  end

  def repo_change(course)
    @course = course
    @repo = course.repo_name
    
    # send to all users of selected repository
    recipients = course.repository.users.map{|u| u.email}
    superadmins = User.where(:superadmin => true).map{|u| u.email}
    recipients += superadmins  
    mail(to: recipients, subject: "[ClassRequestTool] A Class has been Transferred to #{@repo}")
  end
  
  def staff_change(course, current_user)
    @course = course
  
    # send to assigned staff members
    recipients = course.users.map{|u| u.email}
    unless course.primary_contact.blank? || course.primary_contact == current_user
      recipients << course.primary_contact.email
    end
    recipients -= [current_user.email]
 
    mail(to: recipients, subject: "[ClassRequestTool] You have been assigned a class")
  end

  def timeframe_change(course)
    @course = course

    # figure out if there is a primary staff contact, if not send to first staff contact with email
    unless course.primary_contact.blank?
      @staff_email = course.primary_contact.email
      @staff_name = "#{course.primary_contact.full_name}"
    else
      unless course.users.nil?
        course.users.each do |user|
          unless user.email.blank?
            @staff_email = user.email
            @staff_name = "#{user.full_name}"
            break
          end
        end
      end
    end

    unless course.pre_class_appt.blank?
      @pre_class = "<p>Additionally, your pre-class planning appointment is scheduled for #{course.pre_class_appt} with #{name} at #{repository}.</p>"
    end

    # send email to requester
    recipients = [course.contact_email]
    unless course.additional_patrons.blank?
      recipients += course.additional_patrons.map { |p| p.email }
    end
    mail(to: recipients, subject: "[ClassRequestTool] You have been assigned a class")
  end

  def uncancellation(course)
    @course = course

    # Send to primary staff contact, if exists, and to first staff contact with email    
    recipients = Array.new
    unless course.primary_contact.blank?
      recipients << course.primary_contact.email
    end
    unless course.users.nil?
      course.users.each do |user|
        unless user.email.blank?
          recipients << user.email
          break
        end
      end
    end
    
    # Send email
    mail(to: recipients, subject: "[ClassRequestTool] Class uncancellation confirmation")
  end
  
  def send_test_email(email, send_method)
    mail(to: email, subject: "[ClassRequestTool] Test email (#{send_method})")
  end
    
  private
    def deliver_notifications
      if ENV['NOTIFICATIONS_STATUS'] != 'ON'
        mail.perform_deliveries = false
      end
    end
end
