class Repository < ActiveRecord::Base
  attr_accessible :name, :description, :class_limit, :can_edit, :room_ids, :user_ids, :item_attribute_ids, :calendar, :landing_page, :class_policies, :attached_images_attributes
  
  has_many :attached_images, :as => :picture, :dependent => :destroy
  accepts_nested_attributes_for :attached_images, :allow_destroy => true

  has_and_belongs_to_many :users, :order => "last_name"
  has_and_belongs_to_many :rooms
  has_many :courses
  has_and_belongs_to_many :item_attributes
  has_and_belongs_to_many :staff_involvements
  

  validates_presence_of :name
  
end
