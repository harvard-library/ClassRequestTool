class Affiliate < ApplicationRecord  
  validates_presence_of :name

  default_scope { order("position ASC") }
  
end