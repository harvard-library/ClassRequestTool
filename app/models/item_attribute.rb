class ItemAttribute < ActiveRecord::Base
  attr_accessible :name, :description, :room_ids, :repository_ids
  
  has_and_belongs_to_many :rooms
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :courses
end
