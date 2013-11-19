class Note < ActiveRecord::Base
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers
  attr_accessible :note_text, :user_id, :course_id, :staff_comment
  
  belongs_to :user
  belongs_to :course
  
  def new_note_email(current_user)
    # if assigned users is empty, send to all admins of tool 
    if (self.course.primary_contact.nil? || self.course.primary_contact.blank?) && (self.course.users.nil? || self.course.users.blank?)
      repository = self.course.repository.nil? ? 'Not yet assigned' : self.course.repository.name
      
      unless self.course.repository.nil?
        admins = Array.new
        admins << self.course.repository.users
        admins << User.all(:conditions => {:superadmin => true})
        admins.flatten!
      else
        admins = User.all(:conditions => ["admin is true or superadmin is true"]).collect{|a| a == current_user ? '' : a.email}  
      end    
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => admins.join(", "),
        :subject => "[ClassRequestTool] A Comment has been Added to a Class",
        :body => "<p>#{self.user.full_name} (#{self.user.user_type}) has added a note to one of your classes.</p>
        <p>
        Library/Archive: #{repository}<br />
        <a href='#{ROOT_URL}#{course_path(self.course)}'>#{self.course.title}</a><br />
        Subject: #{self.course.subject}<br />
        Course Number: #{self.course.course_number}<br />
        Affiliation: #{self.course.affiliation}<br />
        Number of Students: #{self.course.number_of_students}<br />
        Syllabus: #{self.course.external_syllabus}<br />
        </p>
        <p>Comment: #{self.note_text}</p>"
      )
    # if assigned users is not empty, send to all users assigned to course selected
    else
      emails = self.course.users.collect{|u| u == current_user ? '' : u.email}
      unless self.course.primary_contact.nil? || self.course.primary_contact == current_user
        emails << self.course.primary_contact.email
      end 
      repository = self.course.repository.nil? ? 'Not yet assigned' : self.course.repository.name
      Email.create(
        :from => DEFAULT_MAILER_SENDER,
        :reply_to => DEFAULT_MAILER_SENDER,
        :to => emails.join(", "),
        :subject => "[ClassRequestTool] A Comment has been Added to a Class",
        :body => "<p>#{self.user.full_name} (#{self.user.user_type}) has added a note to one of your classes.</p>
        <p>
        Library/Archive: #{repository}<br />
        <a href='#{ROOT_URL}#{course_path(self.course)}'>#{self.course.title}</a><br />
        Subject: #{self.course.subject}<br />
        Course Number: #{self.course.course_number}<br />
        Affiliation: #{self.course.affiliation}<br />
        Number of Students: #{self.course.number_of_students}<br />
        Syllabus: #{self.course.external_syllabus}<br />
        </p>
        <p>Comment: #{self.note_text}</p>"
      )  
    end  
  end
  
  def new_patron_note_email
    # if note is not staff only send to patron
    repository = self.course.repository.nil? ? 'Not yet assigned' : self.course.repository.name
    Email.create(
      :from => DEFAULT_MAILER_SENDER,
      :reply_to => DEFAULT_MAILER_SENDER,
      :to => self.course.contact_email,
      :subject => "[ClassRequestTool] A Comment has been Added to a Class",
      :body => "<p>#{self.user.full_name} (#{self.user.user_type}) has added a note to one of your classes.</p>
      <p>
      Library/Archive: #{repository}<br />
      <a href='#{ROOT_URL}#{course_path(self.course)}'>#{self.course.title}</a><br />
      Subject: #{self.course.subject}<br />
      Course Number: #{self.course.course_number}<br />
      Affiliation: #{self.course.affiliation}<br />
      Number of Students: #{self.course.number_of_students}<br />
      Syllabus: #{self.course.external_syllabus}<br />
      </p>
      <p>Comment: #{self.note_text}</p>"
    )
  end  
end
