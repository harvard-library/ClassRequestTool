class Admin::CustomText < ActiveRecord::Base  
  validates :key, presence: true, uniqueness: true
  validates :text, presence: true
end
