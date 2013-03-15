class Course < ActiveRecord::Base
  attr_accessible :room_id, :repository_id, :title, :subject, :course_number, :affiliation, :contact_name, :contact_email, :contact_phone, :pre_class_appt, :staff_involvement, :status, :file, :timeframe, :user_ids
  
  has_and_belongs_to_many :users
  belongs_to :room
  belongs_to :repository
  belongs_to :room
  
  validates_presence_of :repository_id, :title, :contact_name, :contact_email, :contact_phone
  
  mount_uploader :file, FileUploader
  
  STAFF_INVOLVEMENT = ['Pre-Class Appointment with Reference Staff (phone or in person)', 'Assistance with Selection of Materials', 'Introduction to Archives and Special Collections Research', 'Assistance with Presentation of Materials in Class', 'No Involvement Required Beyond Set-up']
  
end
