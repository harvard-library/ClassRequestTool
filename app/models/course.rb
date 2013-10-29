class Course < ActiveRecord::Base
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers
  attr_accessible :room_id, :repository_id, :title, :subject, :course_number, :affiliation, :contact_username, :contact_first_name, :contact_last_name, :contact_email, :contact_phone, :pre_class_appt, :staff_involvement, :status, :file, :remove_file, :number_of_students, :timeframe, :timeframe_2, :timeframe_3, :timeframe_4, :user_ids, :external_syllabus, :time_choice_1, :time_choice_2, :time_choice_3, :time_choice_4, :duration, :comments, :course_sessions, :session_count, :item_attribute_ids, :goal, :instruction_session, :pre_class_appt_choice_1, :pre_class_appt_choice_2, :pre_class_appt_choice_3, :staff_involvement_ids, :primary_contact_id
  
  has_and_belongs_to_many :users
  belongs_to :room
  belongs_to :repository
  belongs_to :room
  has_many :notes
  has_and_belongs_to_many :item_attributes
  has_many :assessments
  has_and_belongs_to_many :staff_involvements
  
  
  validates_presence_of :title, :message => "can't be empty"
  validates_presence_of :contact_first_name, :contact_last_name
  validates_presence_of :contact_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"
  validates_presence_of :contact_phone
  
  mount_uploader :file, FileUploader

  COURSE_SESSIONS = ['Single Session', 'Multiple Sessions, Same Materials', 'Multiple Sessions, Different Materials']
  STATUS = ['Scheduled, Unclaimed', 'Scheduled, Claimed', 'Claimed, Unscheduled', 'Unclaimed, Unscheduled', 'Homeless', 'Closed']
  
  def new_request_email
    # send email to requester
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => self.contact_email,
      :subject => "[ClassRequestTool] Class Request Successfully Submitted for #{self.title}",
      :body => "<p>Your class request has been successfully submitted for #{self.title}.</p> 
      <p>You may review your request <a href='#{ROOT_URL}#{course_path(self)}'>here</a> and update it with any new details or comments by leaving a note for staff.</p>
      <p>Thank you for your request. We look forward to working with you.</p>"
    )
    # if repository is empty (homeless), send to all admins of tool 
    if self.repository.nil? || self.repository.blank?
      admins = ""
      User.all(:conditions => ["admin is true or superadmin is true"]).collect{|a| admins = a.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => admins,
        :subject => "[ClassRequestTool] A New Homeless Class  Request has been Received",
        :body => "<p>A new homeless class request has been received in the Class Request Tool.</p> 
        <p>
        Library/Archive: Not yet assigned<br />
        <a href='#{ROOT_URL}#{edit_course_path(self)}'>#{self.title}</a><br />
        Subject: #{self.subject}<br />
        Class Number: #{self.course_number}<br />
        Affiliation: #{self.affiliation}<br />
        Number of Students: #{self.number_of_students}<br />
        Syllabus: #{self.external_syllabus}<br />
        </p>
        <p>If this class is appropriate for your library or archive, please, <a href='#{ROOT_URL}#{edit_course_path(self)}'>edit the course</a> and assign it to your repository.</p>"
      ) 
       
    # if repository is not empty, send to all users assigned to repository selected
    else
      users = ""
      superadmins = ""
      self.repository.users.collect{|u| users = u.email + ","}
      User.all(:conditions => {:superadmin => true}).collect{|s| superadmins = s.email + ","}
      users = users + ", " + superadmins
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => users,
        :subject => "[ClassRequestTool] A new class request has been received for #{self.repository.name}",
        :body => "<p>
        Library/Archive: #{self.repository.name}<br />
        <a href='#{ROOT_URL}#{edit_course_path(self)}'>#{self.title}</a><br />
        Subject: #{self.subject}<br />
        Class Number: #{self.course_number}<br />
        Affiliation: #{self.affiliation}<br />
        Number of Students: #{self.number_of_students}<br />
        Syllabus: #{self.external_syllabus}<br />
        </p>
        <p>If you wish to manage or confirm details, claim this class or assign it to another staff member at #{self.repository.name}, please <a href='#{ROOT_URL}#{edit_course_path(self)}'>edit the course</a>.</p>"
      )
    end  
  end
  
  def send_repo_change_email
    # send to all users of selected repository 
      users = ""
      superadmins = ""
      self.repository.users.collect{|u| users = u.email + ","}
      User.all(:conditions => {:superadmin => true}).collect{|s| superadmins = s.email + ","}
      users = users + ", " + superadmins
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => users,
        :subject => "[ClassRequestTool] A Class has been Transferred to #{self.repository.name}",
        :body => "<p>A class has been transferred to #{self.repository.name}. This may be a formerly Homeless class or a class another repository has suggested would be more appropriate for #{self.repository.name}.</p>
        <p>
        Library/Archive: #{self.repository.name}<br />
        <a href='#{ROOT_URL}#{edit_course_path(self)}'>#{self.title}</a><br />
        Subject: #{self.subject}<br />
        Class Number: #{self.course_number}<br />
        Affiliation: #{self.affiliation}<br />
        Number of Students: #{self.number_of_students}<br />
        Syllabus: #{self.external_syllabus}<br />
        </p>
        <p>If you wish to manage or confirm details, claim this class or assign it to another staff member at #{self.repository.name}, please <a href='#{ROOT_URL}#{edit_course_path(self)}'>edit the course</a>.</p>"
      )    
  end
  
  def send_staff_change_email(current_user)
    # send to assigned staff members
    emails = ""
    self.users.collect{|u| u == current_user ? '' : emails = u.email + ","}
    unless self.primary_contact.nil? || self.primary_contact.blank?
      emails = emails + ", " + self.primary_contact.email
    end  
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => emails,
      :subject => "[ClassRequestTool] You have been assigned a class",
      :body => "<p>You have been assigned to a class for #{self.repository.name}.</p>
      <p>
      Library/Archive: #{self.repository.name}<br />
      <a href='#{ROOT_URL}#{edit_course_path(self)}'>#{self.title}</a><br />
      Subject: #{self.subject}<br />
      Class Number: #{self.course_number}<br />
      Affiliation: #{self.affiliation}<br />
      Number of Students: #{self.number_of_students}<br />
      Syllabus: #{self.external_syllabus}<br />
      </p>
      <p>Please <a href='#{ROOT_URL}#{edit_course_path(self)}'>confirm the class date and time</a> and if applicable, add the class to your event management system (e.g. Aeon) and/or room calendar.</p>"
    )  
  end
  
  def send_timeframe_change_email
    # figure out if there is a primary contact, if not send to first staff contact with email
    unless self.primary_contact.nil? || self.primary_contact.email.blank?
      email = primary_contact.email
      name = "#{self.primary_contact.full_name}"
    else
      unless self.users.nil?
        self.users.each do |user|
          unless user.email.blank?
            email = user.email
            name = "#{user.full_name}"
            break
          end  
        end
      end    
    end  
    
    unless self.pre_class_appt.nil? || self.pre_class_appt.blank?
      pre_class = "<p>Additionally, your pre-class planning appointment is scheduled for #{self.pre_class_appt} with #{name} at #{self.repository.name}.</p>"
    else
      pre_class = ""  
    end  
    
    # send email to requester
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => self.contact_email,
      :subject => "Your class at #{self.repository.name} has been confirmed.",
      :body => "<p>Thank you for submitting your request for a class session at #{self.repository.name}. The request has been reviewed and confirmed.</p>
      <p>Title: <a href='#{ROOT_URL}#{course_path(self)}'>#{self.title}</a><br />
      Confirmed Date: #{self.timeframe}<br />
      Duration: #{self.duration} hours<br />
      Staff contact:<a href='mailto:#{email}'> #{name}</a>
      </p>
      <p>If you have any questions or additional details to share, please add a note to the <a href='#{ROOT_URL}#{course_path(self)}'>class request</a>.</p>
      <p>#{pre_class}</p>"
    ) 
  end
  
  def send_assessment_email 
    # send email to requester
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => self.contact_email,
      :subject => "[ClassRequestTool] Please Assess your Recent Class at #{self.repository.name}",
      :body => "<p>Your class session</p>
      <p>
      Library/Archive: #{self.repository.name}<br />
      <a href='#{ROOT_URL}#{edit_course_path(self)}'>#{self.title}</a><br />
      Subject: #{self.subject}<br />
      Class Number: #{self.course_number}<br />
      Affiliation: #{self.affiliation}<br />
      Number of Students: #{self.number_of_students}<br />
      Syllabus: #{self.external_syllabus}<br />
      </p>
      <p>was recently completed.</p>
      <p>If you would consider taking five minutes to help us improve our services by filling out <a href='#{ROOT_URL}#{new_assessment_path(:course_id => self.id)}'> a short assessment about your experience, we would greatly appreciate it.</a></p>
      <p>Thank you for utilizing #{self.repository.name} in your course. We hope to work with you again soon.</p>"
    )
  end
  
  def primary_contact
    unless self.primary_contact_id.nil?
      User.find(self.primary_contact_id)
    else
      return nil
    end    
  end  
  
  def self.homeless
    #Course.find(:all, :conditions => {:repository_id => nil}, :order => 'timeframe DESC, created_at DESC')
    Course.find(:all, :conditions => {:status => "Homeless"}, :order => 'timeframe DESC, created_at DESC')
  end  
  
  def self.unscheduled_unclaimed
    # courses = Course.order('created_at ASC')
    # unscheduled_unclaimed = Array.new
    # courses.collect{|course| (course.users.empty? && (course.timeframe.nil? || course.timeframe.blank?)) ? unscheduled_unclaimed << course : '' }
    # return unscheduled_unclaimed
    
    Course.find(:all, :conditions => {:status => "Unclaimed, Unscheduled"}, :order => 'timeframe DESC, created_at DESC')
  end
  
  def self.scheduled_unclaimed
    # courses = Course.order('timeframe DESC, created_at DESC')
    # scheduled_unclaimed = Array.new
    # courses.collect{|course| course.users.empty? && (!course.timeframe.nil? && !course.timeframe.blank?) ? scheduled_unclaimed << course : '' }
    # return scheduled_unclaimed
    
    Course.find(:all, :conditions => {:status => "Scheduled, Unclaimed"}, :order => 'timeframe DESC, created_at DESC')
  end 
end
