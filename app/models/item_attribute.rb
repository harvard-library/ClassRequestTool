class ItemAttribute < ApplicationRecord  
  has_and_belongs_to_many :rooms
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :courses
end
