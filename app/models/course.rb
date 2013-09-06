class Course < ActiveRecord::Base
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers
  attr_accessible :room_id, :repository_id, :title, :subject, :course_number, :affiliation, :contact_username, :contact_first_name, :contact_last_name, :contact_email, :contact_phone, :pre_class_appt, :staff_involvement, :status, :file, :number_of_students, :timeframe, :timeframe_2, :timeframe_3, :timeframe_4, :user_ids, :external_syllabus, :time_choice_1, :time_choice_2, :time_choice_3, :time_choice_4, :duration, :comments, :course_sessions, :session_count, :item_attribute_ids, :goal, :instruction_session, :pre_class_appt_choice_1, :pre_class_appt_choice_2, :pre_class_appt_choice_3, :staff_involvement_ids, :primary_contact_id
  
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
      :body => "<p>Class Request Successfully Submitted for #{self.title}.</p> 
      <p>You can review your request <a href='#{ROOT_URL}#{course_path(self)}'>here</a>.</p>"
    )
    # if repository is empty (homeless), send to all admins of tool 
    if self.repository.nil? || self.repository.blank?
      admins = ""
      User.all(:conditions => {:admin => true}).collect{|a| admins = a.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => admins,
        :subject => "[ClassRequestTool] New Homeless Class!",
        :body => "<p>A new homeless class request has been received in the Class Request Tool!</p> <p>See the details below.</p>
        <p>If this is appropriate for your library or archive, <a href='#{ROOT_URL}#{edit_course_path(self)}'>edit the course</a> to reflect its new location.</p>"
      )
    # if repository is not empty, send to all users assigned to repository selected
    else
      users = ""
      self.repository.users.collect{|u| users = u.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => users,
        :subject => "[ClassRequestTool] New class for #{self.repository.name}",
        :body => "<p>A new class request has been received for #{self.repository.name}, or a formerly homeless class has been assigned to #{self.repository.name}.</p> <p>See the details below.</p>
        <p>If you wish to claim this course, or assign it to another staff member at #{self.repository.name}, <a href='#{ROOT_URL}#{edit_course_path(self)}'>edit the course</a> to assign staff.</p>"
      )  
    end  
  end
  
  def updated_request_email
    # if assigned users is empty, send to all admins of tool 
    if self.users.nil? || self.users.blank?
      admins = ""
      User.all(:conditions => {:admin => true}).collect{|a| admins = a.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => admins,
        :subject => "[ClassRequestTool] Unassigned Class Request Updated for #{self.title}",
        :body => "Unassigned Class Request Has Been Updated for #{self.title}"
      )
    # if assigned users is not empty, send to all users assigned to course selected
    else
      emails = ""
      self.users.collect{|u| emails = u.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => emails,
        :subject => "[ClassRequestTool] Class Request Updated for #{self.title}",
        :body => "Class Request Successfully Updated for #{self.title}"
      )  
    end  
  end
  
  def send_repo_change_email
    # send to all users of selected repository 
      users = ""
      self.repository.users.collect{|u| users = u.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => users,
        :subject => "[ClassRequestTool] New class for #{self.repository.name}!",
        :body => "<p>A new class request has been received for #{self.repository.name}, or a formerly homeless class has been assigned to #{self.repository.name}.</p> <p>See the details below.</p>
        <p>If you wish to claim this course, or assign it to another staff member at #{self.repository.name}, <a href='#{ROOT_URL}#{edit_course_path(self)}'>edit the course</a> to assign staff.</p>"
      )   
  end
  
  def send_staff_change_email
    # send to assigned staff members
    emails = ""
    self.users.collect{|u| emails = u.email + ","}
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => emails,
      :subject => "[ClassRequestTool] You have been assigned a class!",
      :body => "<p>Please <a href='#{ROOT_URL}#{edit_course_path(self)}'>confirm the class date and time</a> and if applicable, add the class to your room calendar or event management system (e.g. Aeon).</p>"
    )   
  end
  
  def send_timeframe_change_email
    # send email to requester
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => self.contact_email,
      :subject => "Your class at #{self.repository.name} has been confirmed.",
      :body => "<p>Title: <a href='#{ROOT_URL}#{course_path(self)}'>#{self.title}</a><br />Confirmed Date: #{self.timeframe}<br />Duration: #{self.duration}<br />Staff contact: <staffName>, <staffEmail></p>
      <p>If you have any questions, please add a note to the <a href='#{ROOT_URL}#{course_path(self)}'>class detail</a>, or email the staff member responsible.</p>"
    ) 
  end
  
  def send_assessment_email
    # send email to staff
    users = ""
    self.users.collect{|u| users = u.email + ","}
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => users,
      :subject => "[ClassRequestTool] Class Request Closed for #{self.title}",
      :body => "Class Request Closed for #{self.title}."
    ) 
    # send email to requester
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => self.contact_email,
      :subject => "Please assess your recent class at #{self.repository.name}",
      :body => "<p>Your class session at #{self.repository.name} was recently completed. Please take a minute to help us improve instruction by filling out <a href='#{ROOT_URL}#{new_assessment_path(:course_id => self.id)}'> a short assessment about your experience</a>.</p>"
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
    Course.find(:all, :conditions => {:repository_id => nil}, :order => 'timeframe DESC')
  end  
  
  def self.unscheduled_unclaimed
    courses = Course.order('timeframe DESC')
    unscheduled_unclaimed = Array.new
    courses.collect{|course| (course.users.empty? && (course.timeframe.nil? || course.timeframe.blank?)) ? unscheduled_unclaimed << course : '' }
    return unscheduled_unclaimed
  end
  
  def self.scheduled_unclaimed
    courses = Course.order('timeframe DESC')
    scheduled_unclaimed = Array.new
    courses.collect{|course| course.users.empty? && (!course.timeframe.nil? && !course.timeframe.blank?) ? scheduled_unclaimed << course : '' }
    return scheduled_unclaimed
  end 
end
