class Course < ActiveRecord::Base
  # attr_accessible :title, :body
  
  has_and_belongs_to_many :users
  belongs_to :room
  belongs_to :repository
  belongs_to :room
  
end
