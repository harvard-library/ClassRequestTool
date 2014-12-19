class Affiliate < ActiveRecord::Base
  attr_accessible :name, :url, :description
  
  validates_presence_of :name

  default_scope order("name ASC")
end