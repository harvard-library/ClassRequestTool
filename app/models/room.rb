class Room < ActiveRecord::Base
  attr_accessible :location_id, :name, :repository_ids, :item_attribute_ids, :class_limit
  
  has_and_belongs_to_many :repositories
  has_many :courses
  has_and_belongs_to_many :item_attributes

  validates_presence_of :name, :location_id
end
