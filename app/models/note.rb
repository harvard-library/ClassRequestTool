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
        :subject => "[ClassRequestTool] A comment has been added to a class!",
        :body => "<p>#{self.user.username} has added a note to one of your classes. Click on the title of the class to go to the details of that class.</p>
        <p>Title: <a href='#{ROOT_URL}#{course_path(self.course)}'>#{self.course.title}</a><br /> Course Date: #{self.course.timeframe}<br /> Comment: #{self.note_text}</p>"
      )
    # if assigned users is not empty, send to all users assigned to course selected
    else
      users = ""
      self.course.users.collect{|u| users = u.email + ","}
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => users,
        :subject => "[ClassRequestTool] A comment has been added to a class!",
        :body => "<p>#{self.user.username} has added a note to one of your classes. Click on the title of the class to go to the details of that class.</p>
        <p>Title: <a href='#{ROOT_URL}#{course_path(self.course)}'>#{self.course.title}</a><br /> Course Date: #{self.course.timeframe}<br /> Comment: #{self.note_text}</p>"
      )  
    end  
  end
end
