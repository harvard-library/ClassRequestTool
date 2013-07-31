class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable#, :harvard_auth_proxy_authenticatable        

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :repository_ids, :username
  
  validates_uniqueness_of :username
  
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :repositories, :order => "name"
  has_many :notes
  
  def to_s
    self.full_name
  end
  
  def full_name
    return "#{self.first_name} #{self.last_name}"
  end
  
  def user_type
    if self.admin == true
      return "admin"
    elsif self.staff == true
      return "staff"
    elsif self.patron == true
      return "patron"  
    else
      return "none"  
    end      
  end 
  
  def self.random_password(size = 11)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
    (1..size).collect{|a| chars[rand(chars.size)] }.join
  end
  
  def upcoming_courses
    upcoming = Array.new
    if self.admin?
      Course.all.collect{|course| !course.timeframe.nil? && course.timeframe >= DateTime.now ? upcoming << course : ''}
    else  
      self.courses.collect{|course| !course.timeframe.nil? && course.timeframe >= DateTime.now ? upcoming << course : ''}
    end
    return upcoming
  end
  
  def past_courses
    past = Array.new
    if self.admin?
      Course.all.collect{|course| !course.timeframe.nil? && course.timeframe < DateTime.now ? past << course : ''}
    else  
      self.courses.collect{|course| !course.timeframe.nil? && course.timeframe < DateTime.now ? past << course : ''}
    end
    return past
  end  
  
  def unscheduled_courses
    unscheduled = Array.new
    if self.admin?
      Course.all.collect{|course| course.timeframe.nil? ? unscheduled << course : ''}
    else  
      self.courses.collect{|course| course.timeframe.nil? ? unscheduled << course : ''}
    end
    return unscheduled
  end
  
  def mine_current
    upcoming = Array.new
    upcoming = Course.find(:all, :conditions => ["contact_email = ? and timeframe is NULL or timeframe >= ?", self.email, DateTime.now], :order => 'timeframe DESC')

    return upcoming
  end
  
  def mine_past
    past = Array.new
    past = Course.find(:all, :conditions => ["contact_email = ? and timeframe is not NULL and timeframe < ?", self.email, DateTime.now], :order => 'timeframe DESC')

    return past
  end

end
