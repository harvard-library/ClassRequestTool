class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable#, :harvard_auth_proxy_authenticatable        

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :repository_ids
  # attr_accessible :title, :body
  
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :repositories
  has_many :notes
  
  def to_s
    self.email
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
  
  def mine
    Course.find(:all, :conditions => {:contact_email => self.email}, :order => 'timeframe DESC')
  end

end
