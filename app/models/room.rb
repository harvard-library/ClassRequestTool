class Room < ActiveRecord::Base
  # attr_accessible :title, :body
  
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :courses
  belongs_to :location
end
