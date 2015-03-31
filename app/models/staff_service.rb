class StaffService < ActiveRecord::Base
  attr_accessible :description, :repository_ids, :course_ids, :required, :global
  
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :courses
  
  def to_s
    %Q|#{description}|
  end
end
