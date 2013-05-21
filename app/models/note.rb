class Note < ActiveRecord::Base
  attr_accessible :note_text, :user_id, :course_id
  
  belongs_to :user
  belongs_to :course
  
  def new_note_email
    # if assigned users is empty, send to all admins of tool 
    if self.course.users.nil? || self.course.users.blank?
      admins = ""
      User.all(:conditions => {:admin => true}).collect{|a| admins = a.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => admins,
        :subject => "New Note on Unassigned Class: #{self.course.title}",
        :body => "New Note on Unassigned Class: #{self.course.title}"
      )
    # if assigned users is not empty, send to all users assigned to course selected
    else
      users = ""
      self.course.users.collect{|u| users = u.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => users,
        :subject => "New Note on Class: #{self.course.title}",
        :body => "New Note on Class: #{self.course.title}"
      )  
    end  
  end
end
