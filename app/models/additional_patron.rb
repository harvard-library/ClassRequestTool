class AdditionalPatron < ApplicationRecord
  belongs_to :course
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end
end
