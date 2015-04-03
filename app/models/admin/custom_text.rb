class Admin::CustomText < ActiveRecord::Base
  attr_accessible :key, :text
  
  validates :key, presence: true, uniqueness: true
  validates :text, presence: true
end
