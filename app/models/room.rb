class Room < ActiveRecord::Base

  has_and_belongs_to_many :repositories
  has_many :courses
  has_and_belongs_to_many :item_attributes

  validates_presence_of :name
end
