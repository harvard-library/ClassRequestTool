class AdditionalPatron < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email, :course_id
  belongs_to :course
  validates_format_of :email, with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
end
