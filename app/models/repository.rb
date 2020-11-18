class Repository < ApplicationRecord

  has_and_belongs_to_many :users, :order => "last_name"
  has_and_belongs_to_many :rooms
  has_and_belongs_to_many :item_attributes
  has_and_belongs_to_many :staff_services
  
  has_many :collections, dependent: :destroy
  accepts_nested_attributes_for :collections, reject_if: ->(attributes){ attributes[:name].blank?}, allow_destroy: true
    
  has_many :courses, :dependent => :nullify
  accepts_nested_attributes_for :courses

  has_many :attached_images, :as => :picture, :dependent => :destroy
  accepts_nested_attributes_for :attached_images, :allow_destroy => true, reject_if: :all_blank 

  validates_presence_of :name
  validates :class_policies, format: { :with => URI.regexp }, :if => Proc.new { |a| a.class_policies.present? }
  
  default_scope { order("name ASC") }
  
  def all_staff_services
    self.staff_services.order("description ASC")
  end
  
  def all_technologies
    self.item_attributes.order("name ASC")
  end
  
  def affiliated?(user)
    self.users.include?(user)
  end
  
end
