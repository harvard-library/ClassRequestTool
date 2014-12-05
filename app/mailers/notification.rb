class Notification < ActionMailer::Base
  default from: DEFAULT_MAILER_SENDER
  
  def assessment(course)
    @course = course

    # send email to requester    
    mail(to: course.contact_email, subject: "[ClassRequestTool] Please Assess your Recent Class at #{course.repo_name}").deliver
  end
  
  def cancellation(course)
    @course = course

    # Send to primary contact, if exists, and to first staff contact with email    
    emails = Array.new
    unless course.primary_contact.blank?
      emails << primary_contact.email
    end
    unless course.users.nil?
      course.users.each do |user|
        unless user.email.blank?
          emails << user.email
          break
        end
      end
    end
    
    # Send email
    mail(to: emails.join(','), subject: "[ClassRequestTool] Class cancellation confirmation").deliver
  end
  
  
  def new_request(course)
    @course = course
       
    # send email to requester
    mail(to: course.contact_email, subject: "[ClassRequestTool] Class Request Successfully Submitted for #{course.title}", template_path: 'notifications', template_name: 'new_request_to_requestor').deliver
    
    # If repository is empty (homeless), send to all admins of tool
    if course.repository.blank?
      emails = User.where('admin = ? OR superadmin = ?', true, true).collect{|a| a.email + ","}.join(', ')

    # Otherwise send to all users assigned to the repository
    else
      users = course.repository.users.collect{|u| u.email}
      superadmins = User.all(:conditions => {:superadmin => true}).collect{|s| s.email}
      users << superadmins
      users.flatten!
      emails = users.join(', ')
    end
    
    mail(to: emails, subject: "[ClassRequestTool] A New #{course.repository.blank? ? 'Homeless' : ''} Class Request has been Received", template_path: 'notifications', template_name: 'new_request_to_admin').deliver
  end

  def repo_change(course)
    @course = course
    
    # send to all users of selected repository
    users = course.repository.users.collect{|u| u.email}
    superadmins = User.all(:conditions => {:superadmin => true}).collect{|s| s.email}
    users << superadmins
    users.flatten!
    emails = users.join(', ')
    
    mail(to: emails, subject: "[ClassRequestTool] A Class has been Transferred to #{@repo}").deliver
  end
  
  def staff_change(course, current_user)
    @course = course
  
    # send to assigned staff members
    emails = course.users.collect{|u| u == current_user ? '' : u.email}
    unless course.primary_contact.nil? || course.primary_contact.blank? || course.primary_contact == current_user
      emails << course.primary_contact.email
    end
 
    mail(to: emails, subject: "[ClassRequestTool] You have been assigned a class").deliver
  end

  def timeframe_change(course)
    @course = course

    # figure out if there is a primary contact, if not send to first staff contact with email
    unless course.primary_contact.nil? || course.primary_contact.email.blank?
      @staff_email = primary_contact.email
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
    mail(to: course.contact_email, subject: "[ClassRequestTool] You have been assigned a class").deliver
  end

end
