class StaffInvolvement < ActiveRecord::Base
  attr_accessible :involvement_text, :repository_ids, :course_ids
  
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :courses
  
  def to_s
    %Q|#{involvement_text}|
  end
end
