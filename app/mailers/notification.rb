class Notification < ActionMailer::Base

  include AbstractController::Callbacks    # Includes the after_filter
  add_template_helper(ApplicationHelper)


  default from: Customization.current.nil? ? DEFAULT_MAILER_SENDER : Customization.current.default_email_sender

  def assessment_received_to_admins(assessment)
    fetch_custom_text(__method__.to_s)
    @assessment = assessment

    # Sends to all tool admins
    recipients = User.where('superadmin = ? OR admin = ?', true, true).map{|a| a.email}
    mail(to: recipients, subject: "[ClassRequestTool] Class Assessment Received")
  end

  def assessment_received_to_users(assessment)
    fetch_custom_text(__method__.to_s)
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
    fetch_custom_text(__method__.to_s)
    @course = course

    # send email to requester and additional contacts
    recipients = [course.contact_email]

    unless course.additional_patrons.blank?
      recipients += course.additional_patrons.map { |p| p.email }
    end

    mail(to: recipients, subject: "[ClassRequestTool] Please Assess your Recent Class at #{course.repo_name}")
  end

  def cancellation(course)
    fetch_custom_text(__method__.to_s)
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
    fetch_custom_text(__method__.to_s)
    @courses = Course.where("repository_id IS NULL AND created_at <= ?", Time.now - 2.days)
    unless @courses.blank?
      admins = User.where('admin = ? OR superadmin = ?', true, true).pluck(:email)
      mail(to: admins, subject: "[ClassRequestTool] Homeless classes are languishing!")
    end
  end

  def new_note(note, current_user)
    fetch_custom_text(__method__.to_s)
    @note = note
    @course = @note.course
    repository = @note.course.repo_name

    recipients = []

    # If there are no course contacts/users, send to repository contacts (if any) or else to all admin contacts
    if @note.course.primary_contact.blank? && @note.course.users.blank?
      if @note.course.repository.nil?
        recipients += User.where('admin = ? OR superadmin = ?', true, true).map{|u| u.email }
      else
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

    fetch_custom_text(__method__.to_s)
    @course = course

    # send email to requester
    recipients = [course.contact_email]
    unless course.additional_patrons.blank?
      recipients += course.additional_patrons.map { |p| p.email }
    end
    mail(to: recipients, subject: "[ClassRequestTool] Class Request Successfully Submitted for #{course.title}")
  end

  def new_request_to_admin(course)
    fetch_custom_text(__method__.to_s)
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
    fetch_custom_text(__method__.to_s)
    @course = course
    @repo = course.repo_name

    # send to all users of selected repository
    recipients = course.repository.users.map{|u| u.email}
    superadmins = User.where(:superadmin => true).map{|u| u.email}
    recipients += superadmins
    mail(to: recipients, subject: "[ClassRequestTool] A Class has been Transferred to #{@repo}")
  end

  def staff_change(course, current_user)
    fetch_custom_text(__method__.to_s)
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
    fetch_custom_text(__method__.to_s)
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
    mail(to: recipients, subject: "[ClassRequestTool] Confirmation of time change")
  end

  def uncancellation(course)
    fetch_custom_text(__method__.to_s)
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

  def send_test_email(email, queued_or_unqueued)
    mail(:to => email, :subject => "[ClassRequestTool] Test email (#{queued_or_unqueued})")
  end

  private
  def fetch_custom_text(key) 
    @custom_text = ""
    txt =  Admin::CustomText.where( key: key).first
    if !txt.nil?
      @custom_text = txt.text
    end
  end
end
