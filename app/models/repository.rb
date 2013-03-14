class Repository < ActiveRecord::Base
  attr_accessible :name, :description, :class_limit, :can_edit
  
  has_and_belongs_to_many :users
  has_and_belongs_to_many :rooms
  has_many :courses
end
