class Affiliate < ActiveRecord::Base
  attr_accessible :name, :url, :description, :position
  
  validates_presence_of :name

  default_scope order("position ASC")
  
end