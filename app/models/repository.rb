class Repository < ActiveRecord::Base
  attr_accessible :name, :description, :class_limit, :can_edit, :room_ids, :user_ids, :item_attribute_ids, :calendar, 
      :landing_page, :class_policies, :picture, :attached_images_attributes, :email_details, :collections_attributes
  

  has_and_belongs_to_many :users, :order => "last_name"
  has_and_belongs_to_many :rooms
  has_and_belongs_to_many :item_attributes
  has_and_belongs_to_many :staff_involvements
  
  has_many :collections, dependent: :destroy
  accepts_nested_attributes_for :collections, reject_if: ->(attributes){ attributes[:name].blank?}, allow_destroy: true
    
  has_many :courses
  accepts_nested_attributes_for :courses

  has_many :attached_images, :as => :picture, :dependent => :destroy
  accepts_nested_attributes_for :attached_images, :allow_destroy => true, 
      reject_if: ->(attributes){ attributes['image'].blank? && attributes['image_cache'].blank? }

  validates_presence_of :name
  
  default_scope ->{ order("name ASC") }
  
end
