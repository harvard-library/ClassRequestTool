class StaffService < ApplicationRecord
  
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :courses
  
  def to_s
    %Q|#{description}|
  end
end
