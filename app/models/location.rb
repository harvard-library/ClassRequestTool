class Location < ActiveRecord::Base
  attr_accessible :name
  
  has_many :rooms
  
  validates_presence_of :name
end
