class Collection < ActiveRecord::Base
  belongs_to :repository
  attr_accessible :description, :name, :url
end
