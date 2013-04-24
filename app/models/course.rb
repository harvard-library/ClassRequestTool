class Course < ActiveRecord::Base
  attr_accessible :room_id, :repository_id, :title, :subject, :course_number, :affiliation, :contact_name, :contact_email, :contact_phone, :pre_class_appt, :staff_involvement, :status, :file, :number_of_students, :timeframe, :user_ids, :external_syllabus, :time_choice_1, :time_choice_2, :time_choice_3, :duration, :comments, :course_sessions, :session_count, :item_attribute_ids, :goal, :instruction_session, :pre_class_appt_choice_1, :pre_class_appt_choice_2, :pre_class_appt_choice_3
  
  has_and_belongs_to_many :users
  belongs_to :room
  belongs_to :repository
  belongs_to :room
  has_many :notes
  has_and_belongs_to_many :item_attributes
  has_many :assessments
  has_and_belongs_to_many :staff_involvements
  
  
  validates_presence_of :title, :message => "can't be empty"
  validates_presence_of :contact_name
  validates_presence_of :contact_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"
  validates_presence_of :contact_phone
  
  mount_uploader :file, FileUploader

  COURSE_SESSIONS = ['Single Session', 'Multiple Sessions, Same Materials', 'Multiple Sessions, Different Materials']
  STATUS = ['Pending', 'Scheduled, unclaimed', 'Scheduled, claimed', 'Homeless', 'Closed']
  
  def self.homeless
    Course.find(:all, :conditions => {:repository_id => nil})
  end  
  
  def self.unassigned
    courses = Course.all
    unassigned = Array.new
    courses.collect{|course| course.users.empty? ? unassigned << course : '' }
    return unassigned
  end
  
  def self.roomless
    Course.find(:all, :conditions => {:room_id => nil})
  end 
end
