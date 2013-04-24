class Repository < ActiveRecord::Base
  attr_accessible :name, :description, :class_limit, :can_edit, :room_ids, :user_ids, :item_attribute_ids
  
  has_and_belongs_to_many :users
  has_and_belongs_to_many :rooms
  has_many :courses
  has_and_belongs_to_many :item_attributes
  has_and_belongs_to_many :staff_involvements
  
  validates_presence_of :name
    
end
