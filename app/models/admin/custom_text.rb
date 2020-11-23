class Admin::CustomText < ApplicationRecord  
  validates :key, presence: true, uniqueness: true
  validates :text, presence: true
end
