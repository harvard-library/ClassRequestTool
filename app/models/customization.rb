class HomelessAttributesValidator < ActiveModel::Validator
  def validate(record)
    unless (record.homeless_staff_services & StaffService.all.map(&:id)) == record.homeless_staff_services
      record.errors[:homeless_staff_services] << 'Invalid staff service value(s) for default homeless services.'
    end
    unless (record.homeless_technologies & ItemAttribute.all.map(&:id)) == record.homeless_technologies
      record.errors[:homeless_technologies] << 'Invalid technology value(s) for default homeless technologies.'
    end
  end
end

class Customization < ActiveRecord::Base

#   serialize :homeless_staff_services  // store as PG array
#   serialize :homeless_technologies    // store as PG array
                  
  validates_presence_of :institution, message: 'Please enter the short name for your institution (i.e. Harvard)'
  validates_presence_of :institution_long, message: 'Please enter the long name for your institution (i.e. Harvard University)'
  validates_presence_of :tool_name, message: 'Please enter a name for this tool'
  validates_presence_of :tool_tech_admin_name, message: 'Please enter the name of the tech admin'
  validates :tool_tech_admin_email, presence: { message: 'Please enter an email' }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: 'Please enter a valid email'}
  validates_presence_of :tool_content_admin_name, message: 'Please enter the name of the content admin'
  validates :tool_content_admin_email, presence: { message: 'Please enter an email' }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: 'Please enter a valid email'}
  validates_presence_of :default_email_sender, message: 'Please enter the default address from which this tool will send email'

  validates_with HomelessAttributesValidator 
  
  has_one :attached_image, :as => :picture, :dependent => :destroy
  accepts_nested_attributes_for :attached_image, :allow_destroy => true
end
