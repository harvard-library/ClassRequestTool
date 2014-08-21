class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :harvard_auth_proxy_authenticatable
  #devise :harvard_auth_proxy_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :repository_ids, :username

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


  def full_name
    return "#{self.first_name} #{self.last_name}"
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

  def upcoming_courses
    (Course.where(:status => 'Scheduled, Claimed', :primary_contact_id => id).ordered_by_last_section +
     courses.where(:status => 'Scheduled, Claimed').ordered_by_last_section).uniq
  end

  def past_courses
    (Course.where(:status => 'Closed', :primary_contact_id => id).ordered_by_last_section +
     courses.where(:status => 'Closed').ordered_by_last_section).uniq
  end

  def unscheduled_courses
    (Course.where(:status => 'Claimed, Unscheduled', :primary_contact_id => id).ordered_by_last_section +
     courses.where(:status => "Claimed, Unscheduled").ordered_by_last_section).uniq
  end

  def mine_current
    Course.where(:contact_email => self.email).
      having('MAX(actual_date) >= ?', DateTime.now).
      ordered_by_last_section
  end

  def mine_past
    Course.where(:contact_email => self.email).
      having('MAX(actual_date) IS NOT NULL and MAX(actual_date) < ?', DateTime.now).
      ordered_by_last_section
  end

  def upcoming_repo_courses
    Course.where(:repository_id => self.repository_ids).
      having('MAX(actual_date) IS NOT NULL AND MAX(actual_date) >= ?', DateTime.now).
      ordered_by_last_section
  end

  def classes_to_close
    Course.where("status <> 'Closed' AND primary_contact_id = ?", self.id).
      having("MAX(actual_date) IS NOT NULL AND MAX(actual_date) < ?", DateTime.now).
      ordered_by_last_section
  end

end
