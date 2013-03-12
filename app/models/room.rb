class Room < ActiveRecord::Base
  attr_accessible :location_id, :name
  
  has_and_belongs_to_many :repositories
  has_many :courses, :dependent => :destroy
  belongs_to :location
end
