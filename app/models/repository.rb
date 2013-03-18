class Repository < ActiveRecord::Base
  attr_accessible :name, :description, :class_limit, :can_edit, :room_ids, :user_ids
  
  has_and_belongs_to_many :users
  has_and_belongs_to_many :rooms
  has_many :courses
  
  validates_presence_of :name
end
