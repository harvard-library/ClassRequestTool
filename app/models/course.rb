class Course < ActiveRecord::Base
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers
  attr_accessible :room_id, :repository_id, :title, :subject, :course_number, :affiliation, :contact_username, :contact_first_name, :contact_last_name, :contact_email, :contact_phone, :pre_class_appt, :staff_involvement, :status, :file, :number_of_students, :timeframe, :user_ids, :external_syllabus, :time_choice_1, :time_choice_2, :time_choice_3, :time_choice_4, :duration, :comments, :course_sessions, :session_count, :item_attribute_ids, :goal, :instruction_session, :pre_class_appt_choice_1, :pre_class_appt_choice_2, :pre_class_appt_choice_3, :staff_involvement_ids
  
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
  STATUS = ['Pending', 'Scheduled, unclaimed', 'Scheduled, claimed', 'Claimed, unscheduled', 'Homeless', 'Closed']
  
  def new_request_email
    # send email to requester
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => self.contact_email,
      :subject => "Class Request Successfully Submitted for #{self.title}",
      :body => "Class Request Successfully Submitted for #{self.title}"
    )
    # if repository is empty, send to all admins of tool 
    if self.repository.nil? || self.repository.blank?
      admins = ""
      User.all(:conditions => {:admin => true}).collect{|a| admins = a.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => admins,
        :subject => "[ClassRequestTool] New Homeless Class!",
        :body => "Homeless Class Request Successfully Submitted"
      )
    # if repository is not empty, send to all users assigned to repository selected
    else
      users = ""
      self.repository.users.collect{|u| users = u.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => users,
        :subject => "Class Request Submitted for #{self.repository.name}",
        :body => "Class Request Successfully Submitted"
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
        :subject => "Unassigned Class Request Updated for #{self.title}",
        :body => "Unassigned Class Request Has Been Updated for #{self.title}"
      )
    # if assigned users is not empty, send to all users assigned to course selected
    else
      users = ""
      self.users.collect{|u| users = u.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => users,
        :subject => "Class Request Updated for #{self.title}",
        :body => "Class Request Successfully Updated for #{self.title}"
      )  
    end  
  end
  
  def status_change_email
    # send email to requester
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => self.contact_email,
      :subject => "Class Request Confirmed for #{self.title}",
      :body => "Class Request Confirmed for #{self.title}"
    ) 
  end
  
  def send_assessment_email
    # send email to requester
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => self.contact_email,
      :subject => "Class Request Closed for #{self.title}",
      :body => "Class Request Closed for #{self.title}. Complete a course <a href='#{ROOT_URL}#{new_assessment_path(:course_id => self.id)}'> assessment</a>}."
    ) 
  end
  
  def self.homeless
    Course.find(:all, :conditions => {:repository_id => nil}, :order => 'timeframe DESC')
  end  
  
  def self.unscheduled_unclaimed
    courses = Course.order('timeframe DESC')
    unscheduled_unclaimed = Array.new
    courses.collect{|course| course.users.empty? && (course.timeframe.nil? || course.timeframe.empty?) ? unscheduled_unclaimed << course : '' }
    return unscheduled_unclaimed
  end
  
  def self.scheduled_unclaimed
    courses = Course.order('timeframe DESC')
    scheduled_unclaimed = Array.new
    courses.collect{|course| course.users.empty? && (!course.timeframe.nil? && !course.timeframe.empty?) && (!course.room.nil? && !course.room.empty?) ? scheduled_unclaimed << course : '' }
    return scheduled_unclaimed
  end 
end
