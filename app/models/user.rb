class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :harvard_auth_proxy_authenticatable

  # Use delayed_job to send devise emails
  handle_asynchronously :send_devise_notification, :queue => 'devise'

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :repository_ids, :username, :patron, :staff, :superadmin, :admin

  validates_uniqueness_of :username
  validates_presence_of :username, :unless => :pinuser
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :repositories, :order => "name"
  has_many :notes

  def to_s
    full_name
  end

  def display_name
    return self.full_name == " " ? self.username : self.full_name
  end

  # Custom setters for boolean user type fields
  #===========================================================
  # Ensure that users only have one type by setting others
  #   to false.
  # If user has no type after setting, makes their type patron
  types = %w|patron superadmin admin staff|
  types.each do |type|
    define_method (type + '=').to_sym do |arg|
      write_attribute type, arg
      if arg
        types.reject {|el| el == type}.each do |untype|
          write_attribute untype, false
        end
      elsif user_type == "none"
        write_attribute "patron", true
      end
      arg
    end
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def self.all_admins
    where("admin = true OR superadmin = true")
  end

  def user_type
    if self.superadmin == true
      return "superadmin"
    elsif self.admin == true
      return "admin"
    elsif self.staff == true
      return "staff"
    elsif self.patron == true
      return "patron"
    else
      return "none"
    end
  end

  def can_schedule?
    admin? || staff? || superadmin?
  end

  def self.random_password(size = 11)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
    (1..size).collect{|a| chars[rand(chars.size)] }.join
  end
  
  def can_admin?
    admin? || superadmin?
  end

end
