class Customization < ActiveRecord::Base
  attr_accessible :institution, :institution_long, :tool_name, :slogan, :tool_tech_admin_name, :tool_tech_admin_email, :notifications_on,
                  :tool_content_admin_name, :tool_content_admin_email, :default_email_sender, :attached_image, :attached_image_attributes
                  
  validates_presence_of :institution, message: 'Please enter the short name for your institution (i.e. Harvard)'
  validates_presence_of :institution_long, message: 'Please enter the long name for your institution (i.e. Harvard University)'
  validates_presence_of :tool_name, message: 'Please enter a name for this tool'
  validates_presence_of :tool_tech_admin_name, message: 'Please enter the name of the tech admin'
  validates :tool_tech_admin_email, presence: { message: 'Please enter an email' }, format: { with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, message: 'Please enter a valid email'}
  validates_presence_of :tool_content_admin_name, message: 'Please enter the name of the content admin'
  validates :tool_content_admin_email, presence: { message: 'Please enter an email' }, format: { with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, message: 'Please enter a valid email'}
  validates_presence_of :default_email_sender, message: 'Please enter the default address from which this tool will send email'

  has_one :attached_image, :as => :picture, :dependent => :destroy
  accepts_nested_attributes_for :attached_image, :allow_destroy => true

end
